set lines 200
select GROUP_NUMBER,NAME,STATE,TYPE,TOTAL_MB/1024 "TOTAL GB",FREE_MB/1024 "FREE GB",VOTING_FILES from v$asm_diskgroup;
