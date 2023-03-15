USE [master]
GO 
EXEC master.dbo.sp_addlinkedserver @server = N'ADSI', @srvproduct=N'Active Directory Service Interfaces', @provider=N'ADSDSOObject', @datasrc=N'adsdatasource'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'ADSI',@useself=N'False',@locallogin=NULL,@rmtuser=N'DOMAIN\USER',@rmtpassword='*********'
GO 
EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'collation compatible',  @optvalue=N'false'
GO 
EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'data access', @optvalue=N'true'
GO 
EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'dist', @optvalue=N'false'
GO 
EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'pub', @optvalue=N'false'
GO 
EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'rpc', @optvalue=N'false'
GO 
EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'rpc out', @optvalue=N'false'
GO 
EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'sub', @optvalue=N'false'
GO 
EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'connect timeout', @optvalue=N'0'
GO 
EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'collation name', @optvalue=null
GO 
EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'lazy schema validation',  @optvalue=N'false'
GO 
EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'query timeout', @optvalue=N'0'
GO 
EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'use remote collation',  @optvalue=N'true'
GO 
EXEC master.dbo.sp_serveroption @server=N'ADSI', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO