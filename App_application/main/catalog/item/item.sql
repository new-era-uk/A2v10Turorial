-- Home model
if not exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA = N'app' and DOMAIN_NAME=N'Item.TableType')
create type app.[Item.TableType] as table
(
	Id int,
	[Name] nvarchar(255),
	[Article] nvarchar(10),
	[Memo] nvarchar(255)
);
go
-----------------------------------------------
create or alter procedure app.[Item.Index]
@UserId bigint
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Items!TItem!Array] = null, [Id!!Id] = Id, [Name!!Name] = [Name], Article, Memo
	from app.Items
	order by Id;
end
go
-----------------------------------------------
create or alter procedure app.[Item.Load]
@UserId bigint,
@Id int = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Item!TItem!Object] = null, [Id!!Id] = Id, [Name!!Name] = [Name], Article, Memo
	from app.Items
	where Id = @Id;
end
go
-----------------------------------------------
create or alter procedure app.[Item.Metadata]
as
begin
	declare @Item app.[Item.TableType];
	select [Item2!Item!Metadata] = null, * from @Item;
end
go
-----------------------------------------------
create or alter procedure [app].[Item.Update]
@UserId bigint,
@Item2 app.[Item.TableType] readonly
as
begin
	set nocount on;
	set transaction isolation level read committed;

	/*
	declare @xml nvarchar(max);
	set @xml = (select * from @Item2 for xml auto);
	throw 60000, @xml, 0;
	*/
	declare @rtable table(id int);

	merge app.Items as t
	using @Item2 as s
	on t.Id = s.Id
	when matched then update set
		t.[Name] = s.[Name],
		t.Article = s.Article,
		t.Memo = s.Memo
	when not matched by target then insert 
		([Name], [Article], Memo) values
		(s.[Name], s.Article, s.Memo)
	output inserted.id into @rtable(id);

	declare @newid int;
	select @newid = id from @rtable;

	exec app.[Item.Load] @UserId = @UserId, @Id = @newid;
end
go