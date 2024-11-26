select f.group_number, f.file_number, bytes, space, space/(1024*1024) "InMB", a.name "Name"
from v$asm_file f, v$asm_alias a
where f.group_number=a.group_number and f.file_number=a.file_number
and system_created='Y'
order by f.group_number, f.file_number;