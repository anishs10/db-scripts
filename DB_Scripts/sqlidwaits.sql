select event, sum(wait_time+time_waited) from v$active_session_history where sql_id='&sql_id' group by event order by 2
/
