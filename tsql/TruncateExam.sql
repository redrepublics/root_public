DECLARE @UsePrint bit
SET @UsePrint = 1

IF OBJECT_ID('tempdb.dbo.#FKExams') IS NOT NULL
DROP TABLE #FKExams

CREATE TABLE #FKExams(
PKTABLE_QUALIFIER sysname
, PKTABLE_OWNER	sysname
, PKTABLE_NAME	sysname
, PKCOLUMN_NAME	sysname
, FKTABLE_QUALIFIER	sysname
, FKTABLE_OWNER	sysname
, FKTABLE_NAME	sysname
, FKCOLUMN_NAME	sysname
, KEY_SEQ	int
, UPDATE_RULE	int
, DELETE_RULE	int
, FK_NAME	sysname
, PK_NAME	sysname
, DEFERRABILITY int
)


INSERT #FKExams
exec sp_fkeys 'tExaminations'


DECLARE @FKTableName sysname, @FKColName sysname, @FKName sysname, @SQL nvarchar(500)

DECLARE #cr_FK CURSOR LOCAL
    FOR SELECT FKTABLE_NAME, FKCOLUMN_NAME, FK_NAME
        FROM #FKExams

OPEN #cr_FK

FETCH NEXT FROM #cr_FK
 INTO @FKTableName, @FKColName, @FKName

WHILE (@@fetch_status = 0)
BEGIN
	SET @SQL = N'ALTER TABLE ' + @FKTableName + ' NOCHECK CONSTRAINT ALL'
	EXEC (@SQL)
	if @UsePrint = 1
	print @SQL
	SET @SQL = N'ALTER TABLE ' + @FKTableName + ' DISABLE TRIGGER ALL'
	EXEC (@SQL)
	if @UsePrint = 1
	print @SQL
	SET @SQL = N'ALTER TABLE ' + @FKTableName +  ' DROP CONSTRAINT ' + @FKName
	EXEC (@SQL)	
	if @UsePrint = 1
	print @SQL
	SET @SQL = N'TRUNCATE TABLE ' + @FKTableName 
	EXEC (@SQL)
	if @UsePrint = 1
	print @SQL

	FETCH NEXT FROM #cr_FK
		INTO @FKTableName, @FKColName, @FKName
END

SELECT @FKTableName = 'tExaminations'
	SET @SQL = N'ALTER TABLE ' + @FKTableName + ' NOCHECK CONSTRAINT ALL'
	EXEC (@SQL)
	if @UsePrint = 1
	print @SQL
	SET @SQL = N'ALTER TABLE ' + @FKTableName + ' DISABLE TRIGGER ALL'
	EXEC (@SQL)
	if @UsePrint = 1
	print @SQL
	SET @SQL = N'TRUNCATE TABLE ' + @FKTableName 
	EXEC (@SQL)
	if @UsePrint = 1
	print @SQL
	SET @SQL = N'ALTER TABLE ' + @FKTableName + ' CHECK CONSTRAINT ALL'
	EXEC (@SQL)
	if @UsePrint = 1
	print @SQL
	SET @SQL = N'ALTER TABLE ' + @FKTableName + ' ENABLE TRIGGER ALL'
	EXEC (@SQL)
	if @UsePrint = 1
	print @SQL


CLOSE #cr_FK
DEALLOCATE #cr_FK

DECLARE #cr_Rest CURSOR LOCAL
    FOR SELECT FKTABLE_NAME, FKCOLUMN_NAME, FK_NAME
        FROM #FKExams

OPEN #cr_Rest


FETCH NEXT FROM #cr_Rest
 INTO @FKTableName, @FKColName, @FKName

WHILE (@@fetch_status = 0)
BEGIN
	SET @SQL = N'ALTER TABLE ' + @FKTableName +  ' ADD CONSTRAINT ' + @FKName + ' FOREIGN KEY (' + @FKColName +')
		REFERENCES tExaminations(EID)' 
	EXEC (@SQL)
	if @UsePrint = 1
	print @SQL
	SET @SQL = N'ALTER TABLE ' + @FKTableName + ' CHECK CONSTRAINT ALL'
	EXEC (@SQL)
	if @UsePrint = 1
	print @SQL
	SET @SQL = N'ALTER TABLE ' + @FKTableName + ' ENABLE TRIGGER ALL'
	EXEC (@SQL)
	if @UsePrint = 1
	print @SQL

FETCH NEXT FROM #cr_Rest
 INTO @FKTableName, @FKColName, @FKName
END


CLOSE #cr_Rest
DEALLOCATE #cr_Rest



GO

