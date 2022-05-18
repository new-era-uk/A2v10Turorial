-- Home model
if not exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA = N'app' and DOMAIN_NAME=N'Agent.TableType')
create type app.[Agent.TableType] as table
(
	Id int,
	[Name] nvarchar(255),
	[Code] nvarchar(10),
	[Memo] nvarchar(255)
);
go
-----------------------------------------------
create or alter procedure app.[Agent.Index]
@UserId bigint,
@Id int = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Agents!TAgent!Array] = null, [Id!!Id] = Id, [Name!!Name] = [Name], Code, Memo
	from app.Agents
	order by Id;
end
go
-----------------------------------------------
create or alter procedure app.[Agent.Load]
@UserId bigint,
@Id int = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Agent!TAgent!Object] = null, [Id!!Id] = Id, [Name!!Name] = [Name], Code, Memo
	from app.Agents
	where Id = @Id;
end
go
-----------------------------------------------
create or alter procedure app.[Agent.Metadata]
as
begin
	declare @Agent app.[Agent.TableType];
	select [Agent2!Agent!Metadata] = null, * from @Agent;
end
go
-----------------------------------------------
create or alter procedure [app].[Agent.Update]
@UserId bigint,
@Agent2 app.[Agent.TableType] readonly
as
begin
	set nocount on;
	set transaction isolation level read committed;

	/*
	declare @xml nvarchar(max);
	set @xml = (select * from @Agent2 for xml auto);
	throw 60000, @xml, 0;
	*/
	declare @rtable table(id int);

	merge app.Agents as t
	using @Agent2 as s
	on t.Id = s.Id
	when matched then update set
		t.[Name] = s.[Name],
		t.Code = s.Code,
		t.Memo = s.Memo
	when not matched by target then insert 
		([Name], [Code], Memo) values
		(s.[Name], s.Code, s.Memo)
	output inserted.id into @rtable(id);

	declare @newid int;
	select @newid = id from @rtable;

	exec app.[Agent.Load] @UserId = @UserId, @Id = @newid;
end
go