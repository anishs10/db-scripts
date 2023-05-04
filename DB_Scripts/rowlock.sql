col username for a35
set lines 250
select inst_id,blocking_instance, blocking_session,status,sid as waiting_session, seconds_in_wait,username,sql_id from gv$session where event = 'enq: TX - row lock contention';


