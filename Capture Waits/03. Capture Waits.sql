if object_id('tempdb..#waits') IS NOT NULL
	drop table #waits;

declare	@previous_capture DATETIME

select	@previous_capture = max(collection_time)
from	dbo.wait_collection

select	CURRENT_TIMESTAMP as collection_time,
		wl.wait_id,
		waits.*
into	#waits
from	sys.dm_os_wait_stats waits
join	dbo.wait_list wl on wl.wait_type = waits.wait_type
where	wait_time_ms > 0
and		wl.ignore_flag = 0

/* need to handle resetting the wait stats */
insert dbo.wait_collection (
		collection_time, wait_id
		,waiting_tasks_count, wait_time_ms, max_wait_time_ms, signal_wait_time_ms
		,wait_time_interval, signal_wait_time_interval, interval_ms
		--,wait_time_per_minute, signal_wait_time_per_minute
	)
select 
	cap.collection_time
	,cap.wait_id
	,cap.waiting_tasks_count
	,cap.wait_time_ms
	,cap.max_wait_time_ms
	,cap.signal_wait_time_ms
	,interval_ms = DATEDIFF(ms, @previous_capture, cap.collection_time)
	,wait_time_interval = COALESCE(cap.wait_time_ms - previous.wait_time_ms, 0)
	,signal_wait_time_interval = COALESCE(cap.signal_wait_time_ms - previous.signal_wait_time_ms, 0)

-- ,* 
from #waits cap 
left join dbo.wait_collection previous on previous.wait_id = cap.wait_id
								and previous.collection_time = @previous_capture
order by cap.wait_time_ms DEsC


