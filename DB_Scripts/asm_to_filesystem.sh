#!/bin/bash
## Script to copy Orcl backup files from ASM to disk
## run cron job after backup job (4 a.m. daily) as user grid

## Set variables

# Set target directory for backup files, e.g. /u01/orcl_dailybackup
TARGET_DIR=/u01/orcl_backup

# Set ASM directories to copy, in comma separated list
#ASM_SRC_DIR="+DGFRA/DSTDB/BACKUPSET/, +DGFRA/DSTDB/ARCHIVELOG, +DGFRA/DSTDB/CONTROLFILE"
#ASM_SRC_DIR="+DGFRA/DSTDB2/BACKUPSET/, +DGFRA/DSTDB2/ARCHIVELOG, +DGFRA/DSTDB2/CONTROLFILE"
ASM_SRC_DIR="+DGFRA/DSTDBR/BACKUPSET/,+DGFRA/DSTDBR/ARCHIVELOG, +DGFRA/DSTDBR/CONTROLFILE, +DGFRA/DSTDBR/AUTOBACKUP, +DGFRA/DSTDBR/DATAFILE"

# Set a minimum of disk space available on target device (in bytes), to abort the script and
# avoid filling up the disk by backup copies during night
DSKSPACE_AVAIL_MIN=50000000

# Set alert email sender
#MAIL_SEND=support@cuculus.net
MAIL_SEND=zonos@dst.com

# Set alert email receiver
MAIL_REC=c.knorr@cuculus.net, avnish.singh@subhasree.in, abhishek.bharti@subhasree.in

# Set Orcl env
export ORACLE_HOME=/u01/app/grid/product/19.0.0/grid
export ORACLE_SID=+ASM
ASMCMD_PATH=/u01/app/grid/product/19.0.0/grid/bin

# Set log location
LOG_DIR=/var/log/orcl_backup
LOG_FILE=copy_asm_backup.log

## Checks before copy actions

# Check write permissions on log dir + target dir
# Manually before executing the script: mkdir /var/log/orcl_backup, chown grid:oinstall /var/log/orcl_backup
if ! [ -w $LOG_DIR ]
then
    echo "No permission to write log file to $LOG_DIR."
    LOG_DIR=$ORACLE_BASE/log
    if [ -w $LOG_DIR ]
    then
        echo "Logging to $LOG_DIR."
    else
        exit 1
    fi
fi
LOG_OUT="$LOG_DIR/$LOG_FILE"

if ! [ -w $TARGET_DIR ]
then
    mkdir -p  $TARGET_DIR
    if [ $? -ne 0 ]
    then
        echo "Can't write to $TARGET_DIR."
        exit 1
    fi
fi

# Check user id
CURR_USER="$(whoami)"

if [ "$CURR_USER" != "grid" ]
then
  echo "Execute script as user grid."
  exit 1
fi

# Remove all whitespaces, plus char and trailing slashes from ASM_SRC_DIR, to get a clean list to parse
ASM_SRC_DIR=`echo $ASM_SRC_DIR |awk  'gsub("+","") gsub(/[ \t]+,/, ",") \
              gsub(/,[ \t]+/, ",") gsub("/,",",") sub("/$","") {print $0}'`

# If asm cp command fails check available  disk space in target directory
chk_diskspace()
{
    #DSKSPACE_AVAIL=`df -h $TARGET_DIR  | awk ' !(NR%2) {print $4 " " p} {p=$4}'`
    DSKSPACE_AVAIL=`df $TARGET_DIR  |  awk '(NR>1) {print $4}'`
    if [ $DSKSPACE_AVAIL -lt $DSKSPACE_AVAIL_MIN ]
    then
        echo "Disk space available on target ($(($DSKSPACE_AVAIL / 1024 / 1024)) GB) is less than limit of ($(($DSKSPACE_AVAIL_MIN / 1024 / 1024)) GB) set in ASM copy script." >>$LOG_OUT
        echo "Abort copying ASM backup files to $TARGET_DIR." >>$LOG_OUT
        alert
        return 77
   fi
}

# What to do if  any of the asm copy commands failed
## Disabled due to customer request at 3 Noc 21
alert()
{
    echo "Copy backup files from $ASM_DIR on $(hostname) failed."  >>$LOG_OUT
    #echo "Copy backup files from $ASM_DIR on $(hostname) failed. Check $LOG_OUT." \
    #     | mail -s "Alert: Copy ASM backup failed" -r $MAIL_SEND $MAIL_REC
    #echo "Sent email alert to $MAIL_REC." >>$LOG_OUT
}

## Cleanup: Remove all files in current $ASM_DIR older than 2 days,
## after that remove empty sub folders and folders older than 2 days
#  Added regex to avoid accidentally removing files not copied from ASM,
#  e.g. when target dir is set to wrong directory, variable in find cmd
#  is changed by mistake, ...
#  2 days == 47h + 58m
cleanup()
{
if [ "$CURR_TARGET_DIR" != "" ]
then
    echo "Removing files older than 2 days in $CURR_TARGET_DIR ..." >>$LOG_OUT
    find $CURR_TARGET_DIR -regextype posix-basic -regex '.*\.[0-9]\{10\}' \
         -mmin +2878 -print -exec rm {} \; >>$LOG_OUT 2>/dev/null
fi
if [ "$CURR_TARGET_PARENTDIR" != "" ]
then
    echo "Removing folders older than 2 days in $CURR_TARGET_PARENTDIR ..." >>$LOG_OUT
    find $CURR_TARGET_PARENTDIR -regextype posix-basic -regex \
         '.*[0-9]\{4\}_[0-9]\{2\}_[0-9]\{2\}.*' -type d -mmin +2878 -print -exec rm -r {} \; >>$LOG_OUT 2>/dev/null
    echo "Removing empty folders in $CURR_TARGET_PARENTDIR ..." >>$LOG_OUT 2>/dev/null
    find $CURR_TARGET_PARENTDIR -regextype posix-basic -regex \
         '.*[0-9]\{4\}_[0-9]\{2\}_[0-9]\{2\}.*' -type d -empty -print -exec rmdir {} \; >>$LOG_OUT
fi
# On Primary DB ASM timestamp of 1 source file in the BACKUPSET dir of day
# before yesterday is yesterday. So obsolete BACKUPSET folder can't be removed
# based on timestamp
IS_BCKSET=`echo $CURR_TARGET_PARENTDIR |awk -F/ '{print $NF}'`
if [ "$IS_BCKSET" = "BACKUPSET" ]
then
    for file in $CURR_TARGET_PARENTDIR/*
    do
        OBSOLETE_SUBDIR=`date -d '-2 day' '+%Y_%m_%d'`
        if  [ "$file" = "$CURR_TARGET_PARENTDIR/$OBSOLETE_SUBDIR" ]
        then
            echo "Removing obsolete folders in $IS_BCKSET: " >>$LOG_OUT
            echo "$file" >>$LOG_OUT
            rm -rf $file
        fi
    done
fi
echo >>$LOG_OUT
}

# Updated on customers request (lack of disk space on target dir) to remove all
# backup copies before starting copy of new backup set
if [ "$TARGET_DIR" != "" ]
then
    echo "Removing files in $TARGET_DIR ..." >>$LOG_OUT
    find $TARGET_DIR   -type d -regextype posix-basic -regex '.*20[0-9][0-9]_[01][0-9]_[0123][0-9]' \
         -print -exec rm -rf {} \;   >>$LOG_OUT 2>/dev/null
    find $TARGET_DIR/DATAFILE  -regextype posix-basic -regex '.*\.[0-9]\{10\}' \
         -print -exec rm {} \;   >>$LOG_OUT 2>/dev/null
    find $TARGET_DIR/CONTROLFILE  -regextype posix-basic -regex '.*\.[0-9]\{10\}' \
         -print -exec rm {} \; >>$LOG_OUT 2>/dev/null
fi


## Start copy actions
echo "=======================================================================" >>$LOG_OUT
echo "Starting migration of Oracle ASM backup files at $(date)" >>$LOG_OUT
echo >>$LOG_OUT

# Copy all files  from directories in ASM_SRC_DIR to TARGET_DIR:
# * parse csv string in $ASM_SRC_DIR to loop through all backup srcs dirs
#   and sub folders
# * if ASM source dir does not exist skip it
while [ "$ASM_SRC_DIR" != "$ASM_DIR" ]
do
    ASM_DIR=${ASM_SRC_DIR%%,*}
    ASM_SRC_DIR="${ASM_SRC_DIR#$ASM_DIR,}"

    $ASMCMD_PATH/asmcmd ls $ASM_DIR  >/dev/null 2>>$LOG_OUT
    if [ $? -ne 0 ]
    then
        echo  "Source directory  $ASM_DIR not found. Skip it." >>$LOG_OUT
        alert
        echo >>$LOG_OUT
    else
        echo "Copying ASM files from $ASM_DIR ..." >>$LOG_OUT
        TARGET_SUBDIR=`echo $ASM_DIR | awk -F/ '{print $NF}'`
        if [ ! -d "$TARGET_DIR/$TARGET_SUBDIR" ]
        then
            echo "Creating target dir $TARGET_DIR/$TARGET_SUBDIR ..." >>$LOG_OUT
            mkdir -p "$TARGET_DIR/$TARGET_SUBDIR"
        fi

        # Check available disk space before copying
        chk_diskspace
        if [ $? -eq 77 ] ; then break  ; fi

        # copy all files from current ASM_DIR (if sub dirs copy today's and yesterday's dirs),
        # e.g. BACKUPSET dir contains updated image file in yesterday's sub folder and recent
        #      incremental backup + archived logs in today's folder
        # Since there is no useful option to check with asmcmd ls -l if file is directory
        # get last char of filename - if "/" => directory

        $ASMCMD_PATH/asmcmd ls -l $ASM_DIR |  awk '(NR>1) {print $NF}' | while read -r file
        do
            chkifdir=`echo $file|awk '{print substr($0,length($0),1)}'`
            case $chkifdir in
                "/") subdir=`echo $file | sed 's!/!!g'`
                     CURR_TARGET_DIR="$TARGET_DIR/$TARGET_SUBDIR/$subdir"
                     CURR_TARGET_PARENTDIR="$TARGET_DIR/$TARGET_SUBDIR"
                     if [ "$subdir" = "$(date +%Y_%m_%d -d "today")" ] || \
                        [ "$subdir" = "$(date +%Y_%m_%d -d "yesterday")" ]
                     then
                         echo "Copying files from $file folder ..." >>$LOG_OUT
                         if  [ ! -d "$CURR_TARGET_DIR" ]
                         then
                             echo  "Creating target dir $CURR_TARGET_DIR ..." >>$LOG_OUT
                             mkdir -p  "$CURR_TARGET_DIR"
                         fi

                        $ASMCMD_PATH/asmcmd cp $ASM_DIR/$subdir/* $CURR_TARGET_DIR >>$LOG_OUT 2>&1
                        if [ $? -ne 0 ] ; then alert ; fi
                     else
                         echo "Skipping $subdir, does not match timestamp condition." >>$LOG_OUT
                     fi
                     # cleanup $CURR_TARGET_DIR $CURR_TARGET_PARENTDIR
                     ;;
                "")  echo "No files found in $ASM_DIR" >>$LOG_OUT
                     ;;
                 *)  CURR_TARGET_DIR="$TARGET_DIR/$TARGET_SUBDIR"
                     $ASMCMD_PATH/asmcmd cp $ASM_DIR/* $CURR_TARGET_DIR >>$LOG_OUT 2>&1
                     if [ $? -ne 0 ] ; then alert ; fi
                     # cleanup $CURR_TARGET_DIR
                     break
                     ;;
            esac
        done
    fi
done

echo >>$LOG_OUT
echo "Copying backup files done at $(date)." >>$LOG_OUT
echo "=======================================================================" >>$LOG_OUT
