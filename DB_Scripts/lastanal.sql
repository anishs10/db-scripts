set lines 230
col owner for a12
col table_name for a45
select owner,table_name,num_rows,sample_size,last_analyzed,tablespace_name,global_stats from dba_tables where table_name='&table';
