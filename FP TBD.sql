USE [master];
GO
CREATE DATABASE UserData;
GO
ALTER DATABASE UserData SET RECOVERY FULL;
GO
USE UserData;
GO
CREATE TABLE dbo.LastUpdate(EventTime DATETIME2);
INSERT dbo.LastUpdate(EventTime) SELECT SYSDATETIME();


USE [master];
GO
DECLARE @s NVARCHAR(128) = N'.\PEON1',  -- repeat for .\PEON2, .\PEON3, .\PEON4
        @t NVARCHAR(128) = N'true';
EXEC [master].dbo.sp_addlinkedserver   @server     = @s, @srvproduct = N'SQL Server';
EXEC [master].dbo.sp_addlinkedsrvlogin @rmtsrvname = @s, @useself = @t;
EXEC [master].dbo.sp_serveroption      @server     = @s, @optname = N'collation compatible', @optvalue = @t;
EXEC [master].dbo.sp_serveroption      @server     = @s, @optname = N'data access',          @optvalue = @t;
EXEC [master].dbo.sp_serveroption      @server     = @s, @optname = N'rpc',                  @optvalue = @t;
EXEC [master].dbo.sp_serveroption      @server     = @s, @optname = N'rpc out',              @optvalue = @t;



CREATE TABLE dbo.PMAG_Databases
(
  DatabaseName               SYSNAME,
  LogBackupFrequency_Minutes SMALLINT NOT NULL DEFAULT (15),
  CONSTRAINT PK_DBS PRIMARY KEY(DatabaseName)
);
GO
 
INSERT dbo.PMAG_Databases(DatabaseName) SELECT N'UserData';



CREATE TABLE dbo.PMAG_Secondaries
(
  DatabaseName     SYSNAME,
  ServerInstance   SYSNAME,
  CommonFolder     VARCHAR(512) NOT NULL,
  DataFolder       VARCHAR(512) NOT NULL,
  LogFolder        VARCHAR(512) NOT NULL,
  StandByLocation  VARCHAR(512) NOT NULL,
  IsCurrentStandby BIT NOT NULL DEFAULT 0,
  CONSTRAINT PK_Sec PRIMARY KEY(DatabaseName, ServerInstance),
  CONSTRAINT FK_Sec_DBs FOREIGN KEY(DatabaseName)
    REFERENCES dbo.PMAG_Databases(DatabaseName)
);

INSERT dbo.PMAG_Secondaries
(
  DatabaseName,
  ServerInstance, 
  CommonFolder, 
  DataFolder, 
  LogFolder, 
  StandByLocation
)

SELECT 
  DatabaseName = N'UserData', 
  ServerInstance = name,
  CommonFolder = 'C:\temp\Peon' + RIGHT(name, 1) + '\', 
  DataFolder = 'C:\Program Files\Microsoft SQL Server\MSSQL12.PEON'  
               + RIGHT(name, 1) + '\MSSQL\DATA\',
  LogFolder  = 'C:\Program Files\Microsoft SQL Server\MSSQL12.PEON' 
               + RIGHT(name, 1) + '\MSSQL\DATA\',
  StandByLocation = 'C:\temp\Peon' + RIGHT(name, 1) + '\' 
FROM sys.servers 
WHERE name LIKE N'.\PEON[1-4]';