-- Document model
-----------------------------------------------
create or alter procedure app.[Document.Index]
@UserId bigint,
@Kind nvarchar(32)
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Documents!TDocument!Array] = null, [Id!!Id] = Id, [Date], 
		Memo, [No], [Agent!TAgent!RefId] = Agent, [Sum]
	from app.Documents where Kind = @Kind
	order by Id;

	select [!TAgent!Map] = null, [Id!!Id] = a.Id, [Name!!Name] = a.[Name], a.[Code]
	from app.Agents a
		inner join app.Documents d on a.Id = d.Agent
	where d.Kind = @Kind;


	select [Params!TParam!Object] = null, Kind = @Kind;
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
		Memo, [No], [Agent!TAgent!RefId] = Agent, [Sum],
		[Rows!TRow!Array] = null
	from app.Documents where Id = @Id;

	select [!TRow!Array] = null, [Id!!Id] = Id, Qty, Price, [Sum],
		[Item!TItem!RefId] = Item, [!TDocument.Rows!ParentId] = Document
	from app.Details where Document = @Id;

	select [!TAgent!Map] = null, [Id!!Id] = Id, [Name!!Name] = [Name], [Code]
	from app.Agents 
	where Id in (select Agent from app.Documents where Id = @Id);

	select [Params!TParam!Object] = null, Kind = @Kind;
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