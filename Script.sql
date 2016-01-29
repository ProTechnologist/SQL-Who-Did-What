declare @TableName varchar(50), @query varchar(max)
set @TableName = '' -- CHANGE TABLE NAME HERE

-- temporary table clean up
IF OBJECT_ID('tempdb..#info') IS NOT NULL DROP TABLE #info
IF OBJECT_ID('tempdb..#info2') IS NOT NULL DROP TABLE #info2

-- creating temp table
Create Table #info (TransactionID nvarchar(max), Operation nvarchar(250), Context nvarchar(250),  TableName nvarchar(250))

-- filling temp table
Insert Into #info
	select [Transaction ID], Operation, Context, AllocUnitName
	from fn_dblog(NULL, NULL) where Operation = 'LOP_INSERT_ROWS'
	and AllocUnitName like '%' + convert(varchar,@TableName) + '%'

-- creating copy of #info into @infoUpdated
select * into #info2 from #info

-- adding a few columns for updating information
alter table #info2 add SID varbinary(max) null
alter table #info2 add TranName varchar(max) null
--alter table #info2 add operation varchar(max) null
alter table #info2 add BeginTime DateTime null

declare @sid varbinary(max),
		@TranName varchar(max),
		--@operation varchar(max),
		@BeginTime datetime,
		@TempTranID varchar(max)

-- opening parent level cursor
declare parentCursor cursor forward_only for
select TransactionID from #info2

open parentCursor
fetch next from parentCursor into @tempTranID
while @@FETCH_STATUS = 0
begin
		declare dblogCursor cursor forward_only for
		select [Transaction SID], [Transaction Name], [Begin Time]
		from fn_dblog(NULL, NULL)
		where [Transaction ID] = @TempTranID
		and [Operation] = 'LOP_BEGIN_XACT'

		open dblogCursor
		fetch next from dblogCursor into @sid, @TranName, @BeginTime
		while @@FETCH_STATUS = 0
		begin
			--print convert(varchar, @sid)
			update #info2 set SID = @sid, TranName = @TranName, BeginTime = @BeginTime
			where TransactionID = @TempTranID
			fetch next from dblogCursor into @sid, @TranName, @BeginTime
		end
		close dblogCursor
		deallocate dblogCursor

fetch next from parentCursor into @tempTranID
end
-- select * from #info

-- cleanup
close parentCursor
deallocate parentCursor
drop table #info

-- execute following query for full details.
--select *, SUSER_SNAME(SID) As SqlUser from #info2
-- execute following query with readable details
select SUSER_SNAME(SID) As [User], TranName as Operation, TableName as [Table], BeginTime as Time from #info2
--drop table #info2
