IF EXISTS (select * from sys.server_event_sessions where [name] = 'ErrorSession')
	ALTER EVENT SESSION ErrorSession ON SERVER STATE = STOP

IF EXISTS (select * from sys.server_event_sessions where [name] = 'ErrorSession')
	DROP EVENT SESSION ErrorSession ON SERVER 

CREATE EVENT SESSION ErrorSession ON SERVER 
    ADD EVENT sqlserver.error_reported            
    -- collect failed SQL statement, the SQL stack that led to the error, 
    -- the database id in which the error happened and the username that ran the statement 
    
    (
        ACTION (sqlserver.sql_text, sqlserver.tsql_stack, sqlserver.database_id, 
			sqlserver.username, sqlserver.client_app_name, sqlserver.client_hostname, package0.collect_system_time)
        WHERE severity >= 16 and error_number <> 2557 and error_number <> 17830
    )  
    ADD TARGET package0.ring_buffer    
        (SET max_memory = 1024)
WITH (max_dispatch_latency = 1 seconds, EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS, STARTUP_STATE = ON)

IF EXISTS (select * from sys.server_event_sessions where [name] = 'ErrorSession')
	ALTER EVENT SESSION ErrorSession ON SERVER STATE = START

/*

https://www.sqlskills.com/blogs/jonathan/why-i-hate-the-ring_buffer-target-in-extended-events/
http://blogs.msdn.com/b/psssql/archive/2009/09/17/you-may-not-see-the-data-you-expect-in-extended-event-ring-buffer-targets.aspx

*/