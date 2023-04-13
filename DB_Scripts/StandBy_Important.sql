-- Find which logs were applied in the last day
 SELECT SEQUENCE#, to_char(FIRST_TIME,'hh24:mi:ss dd/mm/yyyy'), to_char(NEXT_TIME,'hh24:mi:ss dd/mm/yyyy'),APPLIED FROM V$ARCHIVED_LOG where next_time>sysdate-1 ORDER BY SEQUENCE# ;


-- Find last applied log
  select to_char(max(FIRST_TIME),'hh24:mi:ss dd/mm/yyyy') FROM V$ARCHIVED_LOG where applied='YES';
 
-- What are the managed standby processes doing?
  SELECT PROCESS, STATUS, THREAD#, SEQUENCE#, BLOCK#, BLOCKS FROM V$MANAGED_STANDBY;
 
-- Are we on production or standby?
 SELECT DATABASE_ROLE, DB_UNIQUE_NAME INSTANCE, OPEN_MODE, PROTECTION_MODE, PROTECTION_LEVEL, SWITCHOVER_STATUS FROM V$DATABASE;
 
-- Check for errors
 SELECT MESSAGE FROM V$DATAGUARD_STATUS;
 
-- Check that the DB was openned correctly 
 SELECT RECOVERY_MODE FROM V$ARCHIVE_DEST_STATUS;

-- important lag statistics
 select * from v$dataguard_stats;


 -- configure log shipping on primary
alter system set log_archive_dest_3='SERVICE=DEVPCOMB LGWR ASYNC VALID_FOR=(ONLINE_LOGFILES, PRIMARY_ROLE) DB_UNIQUE_NAME=DEVPCOMB';
alter system set log_archive_dest_state_3='enable';


-- stopping and starting managed recovery on standby
alter database recover managed standby database cancel;
alter database recover managed standby database disconnect;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE disconnect;


-- Manually register an archive log on standby
alter database register physical logfile '<fullpath/filename>';

-- Check if standby logs are configured right
set lines 100 pages 999
col member format a70
select	st.group#
,	st.sequence#
,	ceil(st.bytes / 1048576) mb
,	lf.member
from	v$standby_log	st
,	v$logfile	lf
where	st.group# = lf.group#
/



-- Gap Check

set linesize 400 pagesize 400
select inst_id,process, status, thread#, sequence#, block#, blocks from gv$managed_standby where process='MRP0';
select a.thread#, (select max (sequence#) from v$archived_log where archived='YES' and thread#=a.thread#) archived,max(a.sequence#) applied, (select max(sequence#) from v$archived_log where archived='YES' and thread#=a.thread#)-max(a.sequence#)gap
from v$archived_log a where a.applied='YES' group by a.thread# order by thread#;



-- Failover Stats

set linesize 140
col fo_time	format a20
col fo_pdt	format a20
col fo_reason	format a80
col min_ago	format 9999
select 	 LAST_FAILOVER_TIME fo_time
	,to_char(new_time(to_date(LAST_FAILOVER_TIME,'MM/DD/YYYY HH24:MI:SS'),'GMT','PDT'), 'MM/DD/YYY HH24:MI:SS') fo_pdt
	,(sysdate - to_date(LAST_FAILOVER_TIME,'MM/DD/YYYY HH24:MI:SS'))*24*60	min_ago
	,LAST_FAILOVER_REASON fo_reason
from V$FS_FAILOVER_STATS;