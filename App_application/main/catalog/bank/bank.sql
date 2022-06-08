/* BANK */
------------------------------------------------
create or alter procedure app.[Bank.Index]
@UserId bigint,
@Offset int = 0,
@PageSize int = 20,
@Order nvarchar(32) = N'name',
@Dir nvarchar(5) = N'asc',
@Fragment nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @fr nvarchar(255);
	set @fr = N'%' + @Fragment + N'%';
	set @Order = lower(@Order);
	set @Dir = lower(@Dir);

	with T(Id, [RowCount], RowNo) as (
	select b.Id, count(*) over (),
		RowNo = row_number() over (order by 
		case when @Dir = N'asc' then
			case @Order
				when N'code' then b.[Code]
				when N'bankcode' then b.[BankCode]
				when N'name' then b.[Name]
				when N'memo' then b.[Memo]
			end
		end asc,
		case when @Dir = N'desc' then
			case @Order
				when N'code' then b.[Code]
				when N'bankcode' then b.[BankCode]
				when N'name' then b.[Name]
				when N'memo' then b.[Memo]
			end
		end desc,
		case when @Dir = N'asc' then
			case @Order
				when N'id' then b.[Id]
			end
		end asc,
		case when @Dir = N'desc' then
			case @Order
				when N'id' then b.[Id]
			end
		end desc,
		b.Id
		)
	from app.Banks b
	where (@fr is null or b.BankCode like @fr or b.Code like @fr 
		or b.[Name] like @fr or b.FullName like @fr or b.Memo like @fr)
	)
	select [Banks!TBank!Array] = null,
		[Id!!Id] = b.Id, [Name!!Name] = b.[Name], b.FullName, 
		b.Code, b.BankCode, b.Memo,
		[!!RowCount] = t.[RowCount]
	from app.Banks b
	inner join T t on t.Id = b.Id
	order by t.RowNo
	offset @Offset rows fetch next @PageSize rows only 
	option(recompile);

	select [!$System!] = null, [!Banks!Offset] = @Offset, [!Banks!PageSize] = @PageSize, 
		[!Banks!SortOrder] = @Order, [!Banks!SortDir] = @Dir,
		[!Banks.Fragment!Filter] = @Fragment
end
go
------------------------------------------------
create or alter procedure app.[Bank.Load]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Bank!TBank!Object] = null,
		[Id!!Id] = b.Id, [Name!!Name] = b.[Name], b.Memo, b.[Code], b.FullName, b.BankCode
	from app.Banks b
	where b.Id = @Id;
end
go
---------------------------------------------
drop procedure if exists app.[Bank.Upload.Metadata];
drop procedure if exists app.[Bank.Upload.Update];
drop procedure if exists app.[Bank.Metadata];
drop procedure if exists app.[Bank.Update];
drop type if exists app.[Bank.Upload.TableType];
drop type if exists app.[Bank.TableType];
go
---------------------------------------------
create type app.[Bank.Upload.TableType] as table
(
	Id bigint,
	[GLMFO] nvarchar(255),
	[SHORTNAME] nvarchar(255),
	[FULLNAME] nvarchar(255),
	[KOD_EDRPOU] nvarchar(50)
)
go
------------------------------------------------
create type app.[Bank.TableType] as table
(
	Id bigint,
	[Code] nvarchar(16),
	[BankCode] nvarchar(16),
	[Name] nvarchar(255),
	[FullName] nvarchar(255),
	[Memo] nvarchar(255)
)
go
---------------------------------------------
create or alter procedure app.[Bank.Metadata]
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @Bank app.[Bank.TableType];
	select [Bank!Bank!Metadata] = null, * from @Bank;
end
go
---------------------------------------------
create or alter procedure app.[Bank.Update]
@UserId bigint,
@Bank app.[Bank.TableType] readonly
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;
	
	declare @output  table (op sysname, id bigint);
	declare @id bigint;

	merge app.Banks as t
	using @Bank as s on t.Id = s.Id
	when matched then update set
		t.[Name] = s.[Name], 
		t.[Memo] = s.[Memo], 
		t.[BankCode] = s.[BankCode],
		t.[FullName] = s.[FullName], 
		t.[Code] = s.[Code]
	when not matched by target then insert
		([Name], Memo, BankCode, FullName, Code) values
		([Name], Memo, BankCode, FullName, Code)
	output $action, inserted.Id into @output (op, id);

	select top(1) @id = id from @output;
	exec app.[Bank.Load] @UserId = @UserId, @Id = @id;
end
go
---------------------------------------------
create or alter procedure app.[Bank.Upload.Metadata]
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @Banks app.[Bank.Upload.TableType];
	select [Banks!Banks!Metadata] = null, * from @Banks;
end
go

---------------------------------------------
create or alter procedure app.[Bank.Upload.Update]
@UserId bigint,
@Banks app.[Bank.Upload.TableType] readonly
as
begin
	set nocount on;
	set transaction isolation level read committed;

	merge app.Banks as t
	using @Banks as s
	on t.BankCode = s.[GLMFO]
	when matched then update set
		t.BankCode = s.[GLMFO],
		t.[Name] =  s.[SHORTNAME],
		t.[Code] = s.KOD_EDRPOU,
		t.[FullName] = s.FULLNAME
	when not matched by target then insert
		(BankCode, [Name], [Code], [FullName]) values
		(s.[GLMFO], [SHORTNAME], KOD_EDRPOU, FULLNAME);

	select [Result!TResult!Object] = null, Loaded = (select count(*) from @Banks);
end
go
------------------------------------------------
create or alter procedure app.[Bank.Delete]
@UserId bigint,
@Id bigint
as
begin
	set nocount on;
	set transaction isolation level read committed;

	delete from app.Banks where Id = @Id;
end
go


