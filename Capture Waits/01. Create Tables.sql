IF OBJECT_ID('dbo.wait_list') IS NOT NULL
	DROP TABLE dbo.wait_list;
GO

CREATE TABLE dbo.wait_list (
	wait_id INT identity(1,1) PRIMARY KEY,
	wait_type NVARCHAR(60) NOT NULL,
	wait_group VARCHAR(32) DEFAULT ('Other'),
	ignore_flag bit default (0)
)

CREATE UNIQUE INDEX ix_wait_list_wait_type ON dbo.wait_list (wait_type);

GO
IF OBJECT_ID('dbo.wait_collection') IS NOT NULL
	DROP TABLE dbo.wait_collection;
GO

CREATE TABLE dbo.wait_collection (
collection_time datetime NOT NULL,
wait_id INT NOT NULL,
waiting_tasks_count bigint,
wait_time_ms bigint,
max_wait_time_ms bigint,
signal_wait_time_ms bigint,
wait_time_interval bigint,
signal_wait_time_interval bigint,
interval_ms bigint,
wait_time_per_minute bigint,
signal_wait_time_per_minute bigint,
CONSTRAINT pk_wait_collecton PRIMARY KEY (collection_time, wait_id)
)


