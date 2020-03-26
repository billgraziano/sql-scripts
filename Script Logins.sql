SET NOCOUNT ON
GO
--use MASTER
GO
PRINT '-----------------------------------------------------------------------------'
PRINT '-- Script created on ' + CAST(GETDATE() AS VARCHAR(100)) + ' from ' + @@Servername
PRINT '-----------------------------------------------------------------------------'
PRINT ''
PRINT '-----------------------------------------------------------------------------'
PRINT '-- Create the windows logins'
PRINT '-----------------------------------------------------------------------------'
SELECT 'IF NOT EXISTS (SELECT * FROM master.sys.server_principals WHERE [name] = ''' + [name] + ''')
	CREATE LOGIN [' + [name] + '] FROM WINDOWS WITH DEFAULT_DATABASE=[' + default_database_name + '], DEFAULT_LANGUAGE=[us_english]
GO

'
FROM sys.server_principals
where type_desc In ('WINDOWS_GROUP', 'WINDOWS_LOGIN')
AND [name] not like 'BUILTIN%'
and [NAME] not like 'NT AUTHORITY%'
and [name] not like '%\SQLServer%'
and [name] not like 'NT Service%'
GO

PRINT '-----------------------------------------------------------------------------'
PRINT '-- Create the SQL Logins'
PRINT '-----------------------------------------------------------------------------'
select 'IF NOT EXISTS (SELECT * FROM master.sys.sql_logins WHERE [name] = ''' + [name] + ''')
	CREATE LOGIN [' + [name] + '] 
		WITH PASSWORD=' + [master].[dbo].[fn_hexadecimal](password_hash) + ' HASHED,
		SID = ' + [master].[dbo].[fn_hexadecimal]([sid]) + ',  
		DEFAULT_DATABASE=[' + default_database_name + '], 
		DEFAULT_LANGUAGE=[us_english], 
		CHECK_EXPIRATION=' + CASE WHEN is_expiration_checked = 1 THEN 'ON' ELSE 'OFF' END + ', 
		CHECK_POLICY=OFF
GO
IF EXISTS (SELECT * FROM master.sys.sql_logins WHERE [name] = ''' + [name] + ''')
	ALTER LOGIN [' + [name] + ']
		WITH CHECK_EXPIRATION=' + CASE WHEN is_expiration_checked = 1 THEN 'ON' ELSE 'OFF' END + ', CHECK_POLICY=' + CASE WHEN is_policy_checked = 1 THEN 'ON' ELSE 'OFF' END + '
GO


'
--[name], [sid] , password_hash 
from sys.sql_logins 
where type_desc = 'SQL_LOGIN' 
and [name] not in ('sa', 'guest')
and [name] not like '##%'

--PRINT '-----------------------------------------------------------------------------'
--PRINT '-- Update Passwords for SQL Logins'
--PRINT '-----------------------------------------------------------------------------'
--SELECT 'ALTER LOGIN [' + [name] + ']
--	WITH PASSWORD=' + dbo.fn_hexadecimal(password_hash) + ' HASHED,
--	CHECK_EXPIRATION=' + CASE WHEN is_expiration_checked = 1 THEN 'ON' ELSE 'OFF' END + ', CHECK_POLICY=' + CASE WHEN is_policy_checked = 1 THEN 'ON' ELSE 'OFF' END + '
--GO

--'
--from sys.sql_logins 
--where type_desc = 'SQL_LOGIN' 
--and [name] not in ('sa', 'guest')

PRINT '-----------------------------------------------------------------------------'
PRINT '-- Disable any disabled logins'
PRINT '-----------------------------------------------------------------------------'
SELECT 'ALTER LOGIN [' + [name] + '] DISABLE
GO
' 
from master.sys.server_principals 
where is_disabled = 1
and [name] not like '##%'

PRINT '-----------------------------------------------------------------------------'
PRINT '-- Assign groups'
PRINT '-----------------------------------------------------------------------------'
select 
'EXEC master..sp_addsrvrolemember @loginame = N''' + l.name + ''', @rolename = N''' + r.name + '''
GO

'
from master.sys.server_role_members rm
join master.sys.server_principals r on r.principal_id = rm.role_principal_id
join master.sys.server_principals l on l.principal_id = rm.member_principal_id
where l.[name] not in ('sa')
AND l.[name] not like 'BUILTIN%'
and l.[NAME] not like 'NT AUTHORITY%'
and l.[name] not like '%\SQLServer%'
and l.[name] not like '##%'
and l.[name] not like 'NT Service%'


