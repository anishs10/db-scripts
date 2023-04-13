column applied_time for a30
set linesize 140
select to_char(sysdate,'mm-dd-yyyy hh24:mi:ss') "Current Time" from dual;
SELECT DB_NAME,  APPLIED_TIME, LOG_ARCHIVED-LOG_APPLIED LOG_GAP ,
(case when ((APPLIED_TIME is not null and (LOG_ARCHIVED-LOG_APPLIED) is null) or 
            (APPLIED_TIME is null and (LOG_ARCHIVED-LOG_APPLIED) is not null) or 
            ((LOG_ARCHIVED-LOG_APPLIED) > 5)) 
      then 'Error! Log Gap is ' 
      else 'OK!' 
 end) Status
FROM
(
SELECT INSTANCE_NAME DB_NAME
FROM GV$INSTANCE
where INST_ID = 1
),
(
SELECT MAX(SEQUENCE#) LOG_ARCHIVED
FROM V$ARCHIVED_LOG WHERE DEST_ID=1 AND ARCHIVED='YES' and THREAD#=1
),
(
SELECT MAX(SEQUENCE#) LOG_APPLIED
FROM V$ARCHIVED_LOG WHERE DEST_ID=2 AND APPLIED='YES' and THREAD#=1
),
(
SELECT TO_CHAR(MAX(COMPLETION_TIME),'DD-MON/HH24:MI') APPLIED_TIME
FROM V$ARCHIVED_LOG WHERE DEST_ID=2 AND APPLIED='YES' and THREAD#=1
)
UNION
SELECT DB_NAME,  APPLIED_TIME, LOG_ARCHIVED-LOG_APPLIED LOG_GAP,
(case when ((APPLIED_TIME is not null and (LOG_ARCHIVED-LOG_APPLIED) is null) or 
            (APPLIED_TIME is null and (LOG_ARCHIVED-LOG_APPLIED) is not null) or 
            ((LOG_ARCHIVED-LOG_APPLIED) > 5)) 
      then 'Error! Log Gap is ' 
      else 'OK!' 
 end) Status
from (
SELECT INSTANCE_NAME DB_NAME
FROM GV$INSTANCE
where INST_ID = 2
),
(
SELECT MAX(SEQUENCE#) LOG_ARCHIVED
FROM V$ARCHIVED_LOG WHERE DEST_ID=1 AND ARCHIVED='YES' and THREAD#=2
),
(
SELECT MAX(SEQUENCE#) LOG_APPLIED
FROM V$ARCHIVED_LOG WHERE DEST_ID=2 AND APPLIED='YES' and THREAD#=2
),
(
SELECT TO_CHAR(MAX(COMPLETION_TIME),'DD-MON/HH24:MI') APPLIED_TIME
FROM V$ARCHIVED_LOG WHERE DEST_ID=2 AND APPLIED='YES' and THREAD#=2
)
/