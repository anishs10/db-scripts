--
-- Top segments in terms of I/Os from AWR
--
@big_job
@plusenv
col objid	format 9999999 		head 'Obj Id'
col obj		format a43		head 'Owner.ObjectName'
col sname	format a30		head 'Sub Object'
col lreads	format 99,999,999,999	head 'Logical Reads'
col dbc		format 99,999,999,999	head 'DB Blk|Changes'
col pread	format 99,999,999,999	head '*Physical Rds*'
col pwrt	format 9,999,999,999	head 'Physical Wrts'
col bbw		format 99,999,999	head 'Bfr Busy|Waits'
col itlw	format 9,999,999	head 'ITL Waits'
col rlw		format 9,999,999	head 'Row Lock|Waits'
col spused	format 99,999,999	head 'Space Used'
col tscan	format 9,999,999	head 'Table|Scans'
col pct_lread	format 999		head 'Pct'
col pct_dbc	format 999		head 'Pct'
col pct_pread	format 999		head 'Pct'
col pct_pwrt	format 999		head 'Pct'

Prompt == Last 7 days ==
select 	 *
from	
(
select 	 s.obj# 			objid
	,o.owner||'.'||o.object_name 	obj
	,o.subobject_name		sname
	,sum(physical_reads_delta)	pread
	,100*ratio_to_report (sum(physical_reads_delta)) over () 	pct_pread
	,sum(physical_writes_delta)	pwrt
	,100*ratio_to_report (sum(physical_writes_delta)) over () 	pct_pwrt
	,sum(logical_reads_delta)	lreads
	,100*ratio_to_report (sum(logical_reads_delta)) over () 	pct_lread
	,sum(db_block_changes_delta)	dbc
	,100*ratio_to_report (sum(db_block_changes_delta)) over () 	pct_dbc
	,sum(buffer_busy_waits_delta)	bbw
	,sum(itl_waits_delta)		itlw
	,sum(row_lock_waits_delta)	rlw
	,sum(table_scans_delta)		tscan
from 	 dba_hist_seg_stat		s
	,dba_hist_seg_stat_obj		o
	,dba_hist_snapshot		sn
where 	 sn.snap_id			= s.snap_id
and	 sn.begin_interval_time		> sysdate - 7
and 	 o.obj# 			= s.obj#
and 	 o.dataobj# 			= s.dataobj#
group by s.obj#
	,o.owner||'.'||o.object_name
	,o.subobject_name
having	 sum(physical_reads_delta)	> 0
order by pread	desc
)
where 	 rownum 	<= 20
;
@big_job_off


