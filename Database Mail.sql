EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
go
EXEC sys.sp_configure N'Database Mail XPs', N'1'
go
RECONFIGURE
go
EXEC sys.sp_configure N'show advanced options', N'0'  RECONFIGURE WITH OVERRIDE
go
EXECUTE msdb.dbo.sysmail_add_account_sp
    @account_name = 'MainAccount',
    --@description = 'Mail account for administrative e-mail.',
    @email_address = 'email@Address.com',
    @display_name = 'ServerName',
    @mailserver_name = 'SMTP----SERVER' ;
GO
EXEC msdb.dbo.sysmail_add_profile_sp @profile_name=N'MainProfile'
GO
EXEC msdb.dbo.sysmail_add_profileaccount_sp @profile_name=N'MainProfile', @account_name=N'MainAccount', @sequence_number=1
GO    
EXEC msdb.dbo.sysmail_delete_principalprofile_sp @principal_name=N'guest', @profile_name=N'MainProfile'
go
EXEC msdb.dbo.sysmail_add_principalprofile_sp @principal_name=N'guest', @profile_name=N'MainProfile', @is_default=1
go 
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'MainProfile',
    @recipients = 'youremail@domain.com',
    @body = 'ServerName Test',
    @subject = 'ServerName Test' ;
 

