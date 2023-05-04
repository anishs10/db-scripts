set linesi 190
col object_name format a32
col object_type format a32
col status format a30
col owner format a10
select owner,object_id,object_name,status from dba_objects where owner=nvl(upper('&owner'),owner) and object_id='&object_id';
