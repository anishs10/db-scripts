set lines 230
col owner for a23
col table_name for a23
select owner,table_name,blocks,num_rows,avg_row_len,round(((blocks*8/1024)),2) "TOTAL_SIZE_MB", round((num_rows*avg_row_len
/1024/1024),2) "ACTUAL_SIZE_MB", round(((blocks*8/1024)-(num_rows*avg_row_len/1024/1024)),2) "FRAGMENTED_SPACE_MB" from
dba_tables where owner in ('ARADMIN') and round(((blocks*8/1024)-(num_rows*avg_row_len/1024/1024)),2)
> 1024 order by 8 desc;
