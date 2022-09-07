USE MASTER
GO

DECLARE @MySQL_VER VARCHAR(10), @SQL_STRING NVARCHAR(4000)

SELECT @MySQL_VER = CASE 
                    WHEN CAST(SERVERPROPERTY ('ProductVersion') AS VARCHAR(10)) LIKE '8.0%' THEN '2000'
                    WHEN CAST(SERVERPROPERTY ('ProductVersion') AS VARCHAR(10)) LIKE '10.5%' THEN '2008'
                    WHEN CAST(SERVERPROPERTY ('ProductVersion') AS VARCHAR(10)) LIKE '11.0%' THEN '2012'
                    ELSE NULL
                    END

/*
  Добавление процедуры sp_tables_info_rowset_64, которая необходима для запуска запросов через линкед-сервер
  при работе 32-битной версии MS SQL Server 2000 с 64-битными версиями MS SQL Server
  (для MS SQL Server 2000)
*/
IF @MySQL_VER = '2000'
BEGIN
    SET @SQL_STRING = 
      'if exists (select 1 from sysobjects where name = N''sp_tables_info_rowset_64'' and type = ''P'')'+CHAR(13)+CHAR(10)+
      '  drop procedure sp_tables_info_rowset_64'
    EXEC (@SQL_STRING)
    SET @SQL_STRING = 
      'create procedure sp_tables_info_rowset_64'+CHAR(13)+CHAR(10)+
      '  @table_name sysname,'+CHAR(13)+CHAR(10)+
      '  @table_schema sysname = null,'+CHAR(13)+CHAR(10)+
      '  @table_type nvarchar(255) = null'+CHAR(13)+CHAR(10)+
      'as'+CHAR(13)+CHAR(10)+
      '  declare @Result int'+CHAR(13)+CHAR(10)+
      '  set @Result = 0'+CHAR(13)+CHAR(10)+
      '  exec @Result = sp_tables_info_rowset @table_name, @table_schema, @table_type'
    EXEC (@SQL_STRING)
END

/*
  Добавление таблиц spt_datatype_info и spt_datatype_info_ext
  (для MS SQL Server версий выше 2000)
*/
IF @MySQL_VER <> '2000'
BEGIN
  IF OBJECT_ID('dbo.spt_datatype_info') IS NULL
  BEGIN
    CREATE TABLE [spt_datatype_info] (
      [TYPE_NAME] [sysname] NOT NULL,
      [DATA_TYPE] [smallint] NOT NULL,
      [data_precision] [int] NULL,
      [LITERAL_PREFIX] [varchar] (32) COLLATE Latin1_General_BIN NULL,
      [LITERAL_SUFFIX] [varchar] (32) COLLATE Latin1_General_BIN NULL,
      [CREATE_PARAMS] [varchar] (32) COLLATE Latin1_General_BIN NULL,
      [NULLABLE] [smallint] NOT NULL,
      [CASE_SENSITIVE] [smallint] NOT NULL,
      [SEARCHABLE] [smallint] NOT NULL,
      [UNSIGNED_ATTRIBUTE] [smallint] NULL,
      [MONEY] [smallint] NOT NULL,
      [AUTO_INCREMENT] [smallint] NULL,
      [LOCAL_TYPE_NAME] [sysname] NULL,
      [MINIMUM_SCALE] [smallint] NULL,
      [MAXIMUM_SCALE] [smallint] NULL,
      [SQL_DATA_TYPE] [smallint] NOT NULL,
      [SQL_DATETIME_SUB] [smallint] NULL,
      [NUM_PREC_RADIX] [int] NULL,
      [INTERVAL_PRECISION] [smallint] NULL,
      [USERTYPE] [smallint] NULL
    )
    INSERT spt_datatype_info EXEC sp_datatype_info
    ALTER TABLE [spt_datatype_info] ADD [ss_dtype] [tinyint]
    UPDATE spt_datatype_info 
      SET [ss_dtype] = xtype 
      FROM systypes 
    WHERE [name] = 
      CASE
        WHEN charindex('(', [TYPE_NAME]) > 0 THEN LEFT([TYPE_NAME], charindex('(', [TYPE_NAME])-1)
        WHEN charindex(' ', [TYPE_NAME]) > 0 THEN LEFT([TYPE_NAME], charindex(' ', [TYPE_NAME])-1)
        ELSE [TYPE_NAME] END 
    ALTER TABLE [spt_datatype_info] ADD [ODBCVer] [tinyint] null
  END
  IF OBJECT_ID('dbo.spt_datatype_info_ext') IS NULL
  BEGIN
    CREATE TABLE [dbo].[spt_datatype_info_ext](
      [user_type] [smallint] NOT NULL,
      [CREATE_PARAMS] [varchar](32) NULL,
      [AUTO_INCREMENT] [smallint] NULL,
      [typename] [sysname] NOT NULL
    ) ON [PRIMARY]
    INSERT spt_datatype_info_ext
    SELECT 106, 'precision,scale', 0, 'decimal'                                                                                                                          UNION ALL
    SELECT 106, 'precision'      , 1, 'decimal'                                                                                                                          UNION ALL
    SELECT 108, 'precision,scale', 0, 'numeric'                                                                                                                          UNION ALL
    SELECT 108, 'precision'      , 1, 'numeric'                                                                                                                          UNION ALL
    SELECT 165, 'max length'     , 0, 'varbinary'                                                                                                                        UNION ALL
    SELECT 167, 'max length'     , 0, 'varchar'                                                                                                                          UNION ALL
    SELECT 173, 'length'         , 0, 'binary'                                                                                                                           UNION ALL
    SELECT 175, 'length'         , 0, 'char'                                                                                                                             UNION ALL
    SELECT 231, 'max length'     , 0, 'nvarchar'                                                                                                                         UNION ALL
    SELECT 239, 'length'         , 0, 'nchar'                                                                                                                            
  END
END

/*
  Установка библиотеки ASPO_XP_MSSQL.dll с внешними процедурами для MS SQL Server
  (для MS SQL Server всех версий)
*/
DECLARE @dll_XP_MSSQL sysname
SET @dll_XP_MSSQL = N'ASPO_XP_MSSQL.dll'
SET NOCOUNT ON
CREATE TABLE #ASPONAMES(xpAspoName sysname)
INSERT #ASPONAMES VALUES(N'xp_ASPOCheckLink')
INSERT #ASPONAMES VALUES(N'xp_ASPOGetRoads')
INSERT #ASPONAMES VALUES(N'xp_ASPOGetDepots')
INSERT #ASPONAMES VALUES(N'xp_ASPOGetStations')
INSERT #ASPONAMES VALUES(N'xp_ASPOGetDepotStations')
INSERT #ASPONAMES VALUES(N'xp_ASPOGetMoveTypes')
INSERT #ASPONAMES VALUES(N'xp_ASPOGetThirdsRoles')
INSERT #ASPONAMES VALUES(N'xp_ASPOGetSuspendReasons')
INSERT #ASPONAMES VALUES(N'xp_ASPOGetProfessions')
INSERT #ASPONAMES VALUES(N'xp_ASPOGetDispanses')
INSERT #ASPONAMES VALUES(N'xp_ASPOGetPersonal')
INSERT #ASPONAMES VALUES(N'xp_ASPOGetRoutesList')
INSERT #ASPONAMES VALUES(N'xp_ASPOGetAttendancesList')
INSERT #ASPONAMES VALUES(N'xp_ASPOGetPersData')
INSERT #ASPONAMES VALUES(N'xp_ASPOPersResult')
INSERT #ASPONAMES VALUES(N'xp_ASPOGetMedical')
INSERT #ASPONAMES VALUES(N'xp_ASPOGetETDID')
INSERT #ASPONAMES VALUES(N'xp_ASPOGetETDID_string')
SET NOCOUNT OFF

DECLARE xpASPO_cursor CURSOR KEYSET
FOR SELECT DISTINCT xpAspoName FROM #ASPONAMES
DECLARE @xpAspoName sysname
OPEN xpASPO_cursor
FETCH NEXT FROM xpASPO_cursor INTO @xpAspoName
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		PRINT 'updating extendedproc for ' + @xpAspoName
		IF EXISTS (SELECT * FROM dbo.sysobjects 
				WHERE id = OBJECT_ID(@xpAspoName) and OBJECTPROPERTY(id, N'IsExtendedProc') = 1)
			EXEC sp_dropextendedproc @xpAspoName
		EXEC sp_addextendedproc @xpAspoName,@dll_XP_MSSQL
	END
	FETCH NEXT FROM xpASPO_cursor INTO @xpAspoName
END
CLOSE xpASPO_cursor
DEALLOCATE xpASPO_cursor
DROP TABLE #ASPONAMES

/*
  Установка параметра 'Ad Hoc Distributed Queries' = 1
  для возможности обмена MS SQL Server 2000 с более поздними версиями
  (для MS SQL Server версий выше 2000)
*/
IF @MySQL_VER <> '2000'
BEGIN
    EXEC sp_configure 'show advanced option', '1'
    RECONFIGURE
    EXEC sp_configure 'Ad Hoc Distributed Queries', '1'
    RECONFIGURE
    EXEC sp_configure 'show advanced option', '0'
    RECONFIGURE
END

GO

