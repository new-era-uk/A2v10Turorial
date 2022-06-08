
-----------------------------------------------
create or alter procedure app.[Report.WebDataRocks.Load]
@UserId bigint
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Sales!TSale!Array] = null, d.[Date],
		[AgentName] = a.[Name], ItemName = i.[Name], j.Qty, j.[Sum]
	from app.Journal j
		inner join app.Documents d on j.Document = d.Id
		left join app.Agents a on d.Agent = a.Id
		left join app.Items i on j.Item = i.Id
	where d.Kind = N'WAYBILLOUT';
end
go
-----------------------------------------------
create or alter procedure app.[Report.ChartJs.Load]
@UserId bigint
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	select [Sales!TSale!Array] = null, d.[Date], Qty = sum(j.Qty), Sum = Sum(j.[Sum])
	from app.Journal j
		inner join app.Documents d on j.Document = d.Id
	where d.Kind = N'WAYBILLOUT'
	group by d.[Date]
end
go
