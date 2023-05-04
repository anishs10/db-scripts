select /*+ ordered */
a.sid "Blocker_SID",a.username "UserName",a.serial#,a.logon_time,
b.type,b.lmode "Mode_Held",b.ctime "Time_Held",c.sid "Waiter_SID",c.request,c.ctime "Time_Waited"
from v$lock b,v$enqueue_lock c, v$session a
where a.sid=b.sid
and b.id1=c.id1(+)
and b.id2=c.id2(+)
and c.type(+)='TX'
and b.type='TX'
and b.block=1
order by b.ctime,c.ctime;
