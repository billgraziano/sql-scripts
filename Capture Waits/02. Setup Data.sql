
/* populate existing wait types */
insert dbo.wait_list (wait_type, wait_group, ignore_flag)
select wait_type  
	,CASE 
		WHEN CHARINDEX('_', wait_type) > 0 THEN 
			LEFT(wait_type, CHARINDEX('_', wait_type) -1)
		ELSE wait_type
	END AS wait_group
	,0 as ignore_flag
from sys.dm_os_wait_stats
where not exists (select * from dbo.wait_list 
				where wait_type  = sys.dm_os_wait_stats.wait_type)
go

/* flag waits to ignore */
update	dbo.wait_list
set ignore_flag = 1
where
	wait_type like 'DBMIRROR%'
	or wait_type like 'HADR%'
or wait_type in (
	'BROKER_EVENTHANDLER',            
	'BROKER_RECEIVE_WAITFOR',
	'BROKER_TASK_STOP',               
	'BROKER_TO_FLUSH',
	'BROKER_TRANSMITTER',              
	'CHECKPOINT_QUEUE',
	'CHKPT',                          
	'CLR_AUTO_EVENT',
	'CLR_MANUAL_EVENT',                
	'CLR_SEMAPHORE',
	'DBMIRROR_DBM_EVENT',             
	'DBMIRROR_DBM_MUTEX',
	'DBMIRROR_WORKER_QUEUE',           
	'DBMIRRORING_CMD',
	'DIRTY_PAGE_POLL',                 
	'DISPATCHER_QUEUE_SEMAPHORE',
	'EXECSYNC',                        
	'FSAGENT',
	'FT_IFTS_SCHEDULER_IDLE_WAIT',    
	'FT_IFTSHC_MUTEX',
	'HADR_CLUSAPI_CALL',               
	'HADR_FILESTREAM_IOMGR_IOCOMPLETIO',
	'HADR_LOGCAPTURE_WAIT',           
	'HADR_NOTIFICATION_DEQUEUE',
	'HADR_TIMER_TASK',                 
	'HADR_WORK_QUEUE',
	'KSOURCE_WAKEUP',                 
	'LAZYWRITER_SLEEP',
	'LOGMGR_QUEUE',                    
	'ONDEMAND_TASK_QUEUE',
	'PWAIT_ALL_COMPONENTS_INITIALIZED',
	'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
	'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
	'REQUEST_FOR_DEADLOCK_SEARCH',     
	'RESOURCE_QUEUE',
	'SERVER_IDLE_CHECK',               
	'SLEEP_BPOOL_FLUSH',
	'SLEEP_DBSTARTUP',                 
	'SLEEP_DCOMSTARTUP',
	'SLEEP_MASTERMDREADY',
	'SLEEP_MASTERUPGRADED',           
	'SLEEP_MSDBSTARTUP',
	'SLEEP_SYSTEMTASK',                
	'SLEEP_TASK',
	'SLEEP_TEMPDBSTARTUP',             
	'SNI_HTTP_ACCEPT',
	'SP_SERVER_DIAGNOSTICS_SLEEP',    
	'SQLTRACE_BUFFER_FLUSH',
	'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
	'SQLTRACE_WAIT_ENTRIES',           
	'WAIT_FOR_RESULTS',
	'WAIT_XTP_CKPT_CLOSE',             
	'WAIT_XTP_HOST_WAIT',             
	'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
	'WAITFOR',                         
	'WAITFOR_TASKSHUTDOW',
	'XE_DISPATCHER_JOI',
	'XE_DISPATCHER_WAIT',              
	'XE_TIMER_EVENT'

)
GO

/* initial population */
insert dbo.wait_collection(collection_time, wait_id, waiting_tasks_count, wait_time_ms, max_wait_time_ms, signal_wait_time_ms, wait_time_interval, signal_wait_time_interval, interval_ms, wait_time_per_minute, signal_wait_time_per_minute)
select	
	CURRENT_TIMESTAMP AS collection_time, 
	wl.wait_id, 
	ws.waiting_tasks_count,
	ws.wait_time_ms, 
	ws.max_wait_time_ms, 
	ws.signal_wait_time_ms, 
	0 AS wait_time_interval, 
	0 AS signal_wait_time_interval, 
	0 AS interval_ms,
	0 AS wait_time_per_minute, 
	0 AS signal_wait_time_per_minute
from	sys.dm_os_wait_stats ws
JOIN	dbo.wait_list wl ON wl.wait_type = ws.wait_type
where	wl.ignore_flag = 0
and		ws.wait_time_ms > 0
--order by wait_time_ms DESC

