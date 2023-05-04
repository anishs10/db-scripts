set lines 230
col table_name for a20
select table_name,avg_row_len,round(((blocks*16/1024)),2)||'MB' "TOTAL_SIZE",
round((num_rows*avg_row_len/1024/1024),2)||'Mb' "ACTUAL_SIZE",
round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2) ||'MB' "FRAGMENTED_SPACE",
(round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2)/round(((blocks*16/1024)),2))*100 "percentage"
from all_tables WHERE table_name='&TABLE_NAME';
