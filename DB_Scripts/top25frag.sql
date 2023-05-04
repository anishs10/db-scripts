set lines 300
col owner for a23
select * from (
select owner,table_name,round((blocks*8),2) "size (kb)" ,
round((num_rows*avg_row_len/1024),2) "actual_data (kb)",
(round((blocks*8),2) - round((num_rows*avg_row_len/1024),2)) "wasted_space (kb)", ((round((blocks * 8), 2) - round((num_rows * avg_row_len / 1024), 2)) /
round((blocks * 8), 2)) * 100 - 10 "reclaimable space % "
from dba_tables
where owner in ('&SCHEMA_NAME' ) and (round((blocks*8),2) > round((num_rows*avg_row_len/1024),2))
order by 5 desc ) where rownum < 25;
