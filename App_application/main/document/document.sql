-- Document model
-----------------------------------------------
create or alter procedure app.[Document.Index]
@UserId bigint,
@Kind nvarchar(32),
@Dir nvarchar(10) = N'desc',
@Order nvarchar(10) = N'Date',
@Offset int = 0,
@PageSize int = 5,
@From date = null,
@To date = null,
@No nvarchar(20) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	set @From = isnull(@From, getdate());
	set @To = isnull(@To, getdate());

	select [Documents!TDocument!Array] = null, [Id!!Id] = Id, [Date], 
		Memo, [No], [Agent!TAgent!RefId] = Agent, [Sum], [Done],
		[!!RowCount] = (select count(*) from app.Documents where Kind = @Kind)
	from app.Documents where Kind = @Kind and [Date] >= @From and [Date] < dateadd(day, 1, @To)
	and (@No is null or [No] like N'%' + @No + N'%')
	order by 
		case when @Dir = N'asc' then
			case @Order
				when N'Date' then [Date]
			end
		end asc,
		case when @Dir = N'desc' then
			case @Order
				when N'Date' then [Date]
			end
		end desc,
		case when @Dir = N'asc' then
			case @Order
				when N'Sum' then [Sum]
			end
		end asc,
		case when @Dir = N'desc' then
			case @Order
				when N'Sum' then [Sum]
			end
		end desc
	offset @Offset rows fetch next @PageSize rows only
	

	select [!TAgent!Map] = null, [Id!!Id] = a.Id, [Name!!Name] = a.[Name], a.[Code]
	from app.Agents a
		inner join app.Documents d on a.Id = d.Agent
	where d.Kind = @Kind;


	select [Params!TParam!Object] = null, Kind = @Kind;

	select [!$System!] = null, 
		[!Documents!SortOrder] = @Order, [!Documents!SortDir] = @Dir,
		[!Documents!Offset] = @Offset, [!Documents!PageSize] = @PageSize,
		[!Documents.Period.From!Filter] = @From, [!Documents.Period.To!Filter]= @To,
		[!Documents.No!Filter] = @No;
end
go

-----------------------------------------------
create or alter procedure app.[Document.Load]
@UserId bigint,
@Kind nvarchar(32),
@Id int = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Document!TDocument!Object] = null, [Id!!Id] = Id, [Date], 
		Memo, [No], [Agent!TAgent!RefId] = Agent, [Sum], [Done],
		[Rows!TRow!Array] = null
	from app.Documents where Id = @Id;

	select [!TRow!Array] = null, [Id!!Id] = Id, Qty, Price, [Sum],
		[Item!TItem!RefId] = Item, [!TDocument.Rows!ParentId] = Document
	from app.Details where Document = @Id;

	select [!TItem!Array] = null, [Id!!Id] = i.Id, [Name!!Name] = i.[Name]
	from app.Items i inner join app.Details dd on i.Id = dd.Item
	where dd.Document = @Id;

	select [!TAgent!Map] = null, [Id!!Id] = Id, [Name!!Name] = [Name], [Code]
	from app.Agents 
	where Id in (select Agent from app.Documents where Id = @Id);

	select [Params!TParam!Object] = null, Kind = @Kind;

	select [!$System!] = null, [!!ReadOnly] = Done from app.Documents where Id=@Id;
end
go
-----------------------------------------------
drop procedure if exists app.[Document.Metadata];
drop procedure if exists app.[Document.Update];
drop type if exists app.[Document.TableType];
drop type if exists app.[Detail.TableType];
go
-----------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA = N'app' and DOMAIN_NAME=N'Document.TableType')
create type app.[Document.TableType] as table
(
	Id int,
	[Date] date,
	[No] nvarchar(10),
	[Memo] nvarchar(255),
	Agent int,
	[Sum] money
);
go
-----------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA = N'app' and DOMAIN_NAME=N'Detail.TableType')
create type app.[Detail.TableType] as table
(
	Id int,
	Item int,
	Qty float,
	Price float,
	[Sum] money
);
go
-----------------------------------------------
create or alter procedure app.[Document.Metadata]
as
begin
	set nocount on;
	declare @Document app.[Document.TableType];
	declare @Detail app.[Detail.TableType];
	select [Document!Document!Metadata] = null, * from @Document;
	select [Rows!Document.Rows!Metadata] = null, * from @Detail;
	
end
go
-----------------------------------------------
create or alter procedure app.[Document.Update]
@UserId bigint,
@Document app.[Document.TableType] readonly,
@Rows app.[Detail.TableType] readonly,
@Kind nvarchar(32)
as
begin
	set nocount on;
	/*
	declare @xml nvarchar(max);
	set @xml = (select * from @Document for xml auto);
	throw 60000, @xml, 0;
	*/
	declare @rtable table(id int);

	merge app.Documents as t
	using @Document as s
	on t.Id = s.Id
	when matched then update set
		t.[Date] = s.[Date],
		t.[No] = s.[No],
		t.Memo = s.Memo,
		t.Agent = s.Agent,
		t.[Sum] = s.[Sum]
	when not matched by target then insert 
		(Kind, [Date], [No], Memo, Agent, [Sum]) values
		(@Kind, s.[Date], s.[No], s.Memo, s.Agent, [Sum])
	output inserted.id into @rtable(id);

	declare @newid int;
	select @newid = id from @rtable;

	merge app.Details as t
	using @Rows as s
	on t.Id = s.Id and t.Document = @newid
	when matched then update set
		t.Item = s.Item,
		t.Qty = s.Qty,
		t.Price = s.Price,
		t.[Sum] = s.[Sum]
	when not matched by target then insert 
		(Document, Item, Qty, Price, [Sum]) values
		(@newid, s.Item, s.Qty, s.Price, s.[Sum]);

	exec app.[Document.Load] @UserId = @UserId, @Id = @newid, @Kind = @Kind;

end
go
-----------------------------------------------
create or alter procedure app.[Document.Apply]
@UserId bigint,
@Id bigint
as
begin
	set nocount on;
	set transaction isolation level read committed;

	declare @Done bit;
	declare @Kind nvarchar(255);

	select @Done = Done, @Kind = Kind from app.Documents where Id=@Id;
	if @Done = 1
		throw 60000, N'UI:Document already applied', 0;
	
	begin tran
		update app.Documents set Done = 1 where Id = @Id;
		insert into app.Journal (Document, [Date], Item, InOut, Qty, [Sum])
		select Document, getdate(), Item, 
			case @Kind 
				when N'WAYBILLIN' then 1 
				when N'WAYBILLOUT' then -1
			end, 
			Qty, [Sum]
			from app.Details where Document = @Id
	commit tran;
end
go

-----------------------------------------------
create or alter procedure app.[Document.UnApply]
@UserId bigint,
@Id bigint
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;

	declare @Done bit;
	select @Done = Done from app.Documents where Id=@Id;
	if @Done = 0
		throw 60000, N'UI:Document has not applied yet', 0;
	begin tran
		update app.Documents set Done = 0 where Id = @Id;
		delete from app.Journal where Document = @Id;
	commit tran;
end
go