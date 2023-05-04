

col index_owner for a20
col table_name for a20
col index_name for a40
col column_name for a20
Select index_owner, table_name, index_name, column_name
FROM dba_ind_columns
where index_owner in ('ARADMIN','SYS')
AND table_name='&table';
