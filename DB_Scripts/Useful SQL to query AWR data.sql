Useful SQL to query AWR data
1) Top CPU consuming Session in last 5 minutes

SELECT session_id,
       COUNT(*)
FROM   v$active_session_history
WHERE  session_state = 'ON CPU'
       AND sample_time > sysdate - ( 5 / ( 24 * 60 ) )
GROUP  BY session_id
ORDER  BY COUNT(*) DESC;


2) Top Waiting Session in last 5 minutes

SELECT session_id,
       COUNT(*)
FROM   v$active_session_history
WHERE  session_state = 'WAITING'
       AND sample_time > sysdate - ( 5 / ( 24 * 60 ) )
GROUP  BY session_id
ORDER  BY COUNT(*) DESC;


3) Top Waiting Event in last 5 minutes

SELECT event,
       COUNT(*)
FROM   v$active_session_history
WHERE  session_state = 'WAITING'
       AND sample_time > sysdate - ( 5 / ( 24 * 60 ) )
GROUP  BY event
ORDER  BY COUNT(*) DESC;


4) Top Active Machine in last 5 minutes

SELECT machine,
       COUNT(*)
FROM   v$active_session_history
WHERE sample_time > sysdate - ( 5 / ( 24 * 60 ) )
GROUP  BY machine
ORDER  BY COUNT(*) DESC;


5) Top SESSION by CPU usage, wait time and IO time in last 5 minutes

select
ash.session_id,
ash.session_serial#,
ash.user_id,
ash.program,
sum(decode(ash.session_state,'ON CPU',1,0)) "CPU",
sum(decode(ash.session_state,'WAITING',1,0)) -
sum(decode(ash.session_state,'WAITING',
decode(en.wait_class,'User I/O',1, 0 ), 0)) "WAITING" ,
sum(decode(ash.session_state,'WAITING',
decode(en.wait_class,'User I/O',1, 0 ), 0)) "IO" ,
sum(decode(session_state,'ON CPU',1,1)) "TOTAL"
from v$active_session_history ash,
v$event_name en
where en.event# = ash.event# AND SAMPLE_TIME >  SYSDATE - (5/(24*60))
group by session_id,user_id,session_serial#,program
order by sum(decode(session_state,'ON CPU',1,0));


6) Top SQL by CPU usage, wait time and IO time in last 5 minutes

SELECT ash.sql_id,
       SUM(DECODE(ash.session_state, 'ON CPU', 1, 0))        "CPU",
       SUM(DECODE(ash.session_state, 'WAITING', 1, 0))
               - SUM( DECODE(ash.session_state, 'WAITING', DECODE(en.wait_class, 'User I/O', 1, 0), 0)) "WAIT",
       SUM(DECODE(ash.session_state, 'WAITING',  DECODE(en.wait_class, 'User I/O', 1, 0),  0))        "IO",
       SUM(DECODE(ash.session_state, 'ON CPU', 1,   1))       "TOTAL"
FROM   v$active_session_history ash,
       v$event_name en
WHERE  sql_id IS NOT NULL AND SAMPLE_TIME >  SYSDATE - (5/(24*60))
       AND en.event# = ash.event#
GROUP  BY sql_id
ORDER  BY SUM(DECODE(session_state, 'ON CPU', 1, 0)) DESC;