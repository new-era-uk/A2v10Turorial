-- database stucture
if not exists(select * from INFORMATION_SCHEMA.SCHEMATA where SCHEMA_NAME=N'app')
	exec sp_executesql N'create schema app';
go
-----------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = N'app' and TABLE_NAME = N'Agents')
create table app.Agents(
	Id int identity(100, 1)
		constraint PK_Agents primary key,
	[Name] nvarchar(255),
	[Code] nvarchar(10),
	[Memo] nvarchar(255)
)
go
-----------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = N'app' and TABLE_NAME = N'Items')
create table app.Items(
	Id int identity(100, 1)
		constraint PK_Items primary key,
	[Name] nvarchar(255),
	[Article] nvarchar(10),
	[Memo] nvarchar(255)
)
go
-----------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = N'app' and TABLE_NAME = N'Banks')
create table app.Banks(
	Id int identity(100, 1)
		constraint PK_Banks primary key,
	[Name] nvarchar(255),
	[FullName] nvarchar(255),
	[Code] nvarchar(10),
	[BankCode] nvarchar(12),
	[Memo] nvarchar(255)
)
go

-----------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = N'app' and TABLE_NAME = N'Documents')
create table app.Documents(
	Id int identity(100, 1)
		constraint PK_Documents primary key,
	Kind nvarchar(32),
	[Date] date,
	[No] nvarchar(10),
	[Agent] int
		constraint FK_Documents_Agent_Agents references app.Agents(Id),
	[Memo] nvarchar(255),
	[Sum] money,
	Done bit
)
go
-----------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME=N'Documents' and COLUMN_NAME=N'Sum')
	alter table app.Documents add [Sum] money;
go
-----------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME=N'Documents' and COLUMN_NAME=N'Done')
	alter table app.Documents add Done bit;
go
-----------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = N'app' and TABLE_NAME = N'Details')
create table app.Details(
	Id int identity(100, 1)
		constraint PK_Details primary key,
	[Document] int
		constraint FK_Details_Document_Documents references app.Documents(Id),
	[Item] int
		constraint FK_Details_Item_Items references app.Items(Id),
	Qty float,
	Price float,
	[Sum] money
)
go

-----------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = N'app' and TABLE_NAME = N'Journal')
create table app.Journal(
	Id int identity(100, 1)
		constraint PK_Journal primary key,
	[Date] date,
	[Document] int
		constraint FK_Journal_Document_Documents references app.Documents(Id),
	[Item] int
		constraint FK_Journal_Item_Items references app.Items(Id),
	InOut smallint, -- "1" In, "-1" - Out
	Qty float,
	[Sum] money
)
go
