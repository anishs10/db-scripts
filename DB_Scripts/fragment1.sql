
select owner,table_name,round((blocks*8),2)||' kb' "TABLE SIZE",round((num_rows*avg_row_len/1024),2)||' kb' "ACTUAL DATA" from dba_tables where table_name='&table';

