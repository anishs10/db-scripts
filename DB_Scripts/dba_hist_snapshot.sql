col snap_id		format 99999
col ServerTime		format a18
col MyTime		format a18
select 	 snap_id
	,to_char(BEGIN_INTERVAL_TIME,'YYYY/MM/DD HH24:MI')			  ServerTime
	,to_char(new_time(BEGIN_INTERVAL_TIME+(5.5/24),'GMT','GMT'),'YYYY/MM/DD HH24:MI') MyTime
from 	 dba_hist_snapshot
order by 1
;
select 	 to_char(min(BEGIN_INTERVAL_TIME),'YYYY/MM/DD HH24:MI')	MinServer
	,to_char(new_time(min(BEGIN_INTERVAL_TIME),'GMT','PDT'),'YYYY/MM/DD HH24:MI') MinMyTime
	,to_char(max(BEGIN_INTERVAL_TIME),'YYYY/MM/DD HH24:MI') MaxServer
	,to_char(new_time(max(BEGIN_INTERVAL_TIME),'GMT','PDT'),'YYYY/MM/DD HH24:MI') MaxMyTime
from     dba_hist_snapshot
;




[oracle@pmdb01b anish]$ cat pchange.sql
set lines 155
col execs for 999,999,999
col avg_etime for 999,999.999
col avg_lio for 999,999,999.9
col begin_interval_time for a30
col node for 99999
break on plan_hash_value on startup_time skip 1
select ss.snap_id, ss.instance_number node, begin_interval_time, sql_id, plan_hash_value,
nvl(executions_delta,0) execs,
(elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 avg_etime,
(buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) avg_lio
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where sql_id = nvl('&sql_id','4dqs2k5tynk61')
and ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number
and executions_delta > 0
order by 1, 2, 3
/
