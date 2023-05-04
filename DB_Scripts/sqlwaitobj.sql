select current_obj#,p3,sum(wait_time+time_Waited) from v$active_session_history where sql_id='&sql_id' group by current_obj#,p3
/
