select wl.wait_type, wc.*
from dbo.wait_collection wc
join dbo.wait_list wl on wl.wait_id = wc.wait_id
where collection_time = (select MAX(collection_time) from dbo.wait_collection)
order by wait_time_interval desc

select wl.wait_group, sum(wc.wait_time_interval), SUM(wc.signal_wait_time_interval), max(interval_ms)
from dbo.wait_collection wc
join dbo.wait_list wl on wl.wait_id = wc.wait_id
where collection_time = (select MAX(collection_time) from dbo.wait_collection)
group by wl.wait_group
order by sum(wc.wait_time_interval) desc