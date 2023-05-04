set linesi 190
set pagesi 10000
col COMPONENT format a30
col PARAMETER format a23
select COMPONENT,OPER_TYPE,OPER_MODE,PARAMETER,INITIAL_SIZE/(1024*1024) initial_size,TARGET_SIZE/(1024*1024) target_size,FINAL_SIZE/(1024*1024) final_size,STATUS,START_TIME,END_TIME from v$sga_resize_ops;

