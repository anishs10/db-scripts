set linesi 190
col name format a40
col parameter1 format a40
col parameter2 format a40
col parameter3 format a40
select name,parameter1,parameter2,parameter3 from v$event_name where name like '%&1%';

