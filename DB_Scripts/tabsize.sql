

column owner format a20;
column table_name format a30;
column "SIZE (GB)" format 99999.99;
select * from (select owner, segment_name table_name, bytes/1024/1024/1024 "SIZE (GB)" from dba_segments where segment_type = 'TABLE' and segment_name='&object_name');
