col table_name for a24
col owner for a24
select OWNER,TABLE_NAME,OBJECT_TYPE,NUM_ROWS,LAST_ANALYZED,STALE_STATS from dba_tab_statistics where OWNER='&OWNER' and TABLE_NAME='&Table'; 

