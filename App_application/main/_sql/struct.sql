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
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = N'app' and TABLE_NAME = N'Documents')
create table app.Documents(
	Id int identity(100, 1)
		constraint PK_Documents primary key,
	Kind nvarchar(32),
	[Date] date,
	[No] nvarchar(10),
	[Agent] int
		constraint FK_Documents_Agent_Agents references app.Agents(Id),
	[Memo] nvarchar(255)
)
go

