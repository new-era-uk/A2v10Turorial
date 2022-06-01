-- Home model
-----------------------------------------------
create or alter procedure app.[Report.Item.Rem.Load]
@UserId bigint,
@Date date = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	set @Date = isnull(@Date, getdate());

	with T as (
		select Qty = sum(Qty * InOut), Item 
		from app.Journal
		where [Date] <= @Date
		group by Item
	)
	select [RepData!TRepData!Array] = null, Qty,
		[Item.Id!TItem!] = T.Item, [Item.Name!TItem!] = isnull(i.[Name], N'Unknown')
	from T
	left join app.Items i on T.Item = i.Id;


	select [Query!TQuery!Object] = null,
		[Date] = @Date;
end
go

create or alter procedure app.[Report.Item.Sales.Load]
@UserId bigint,
@From date = null,
@To date = null
as
begin
	set nocount on;

	set @From = isnull(@From, N'20220101');
	set @To = isnull(@To, N'20221231');

	with T as (
		select Qty = sum(Qty), [Sum] = sum(j.[Sum]), d.Agent, j.Item,
			GrpAgent = grouping(d.Agent),
			GrpItem = grouping(j.Item)
		from app.Journal j 
		inner join app.Documents d on j.Document = d.Id
		where d.Kind = N'WAYBILLOUT' and j.[Date] >= @From and j.[Date] <= @To
		group by rollup(d.Agent, j.Item)
	)
	select [RepData!TRepData!Group] = null, Qty, [Sum], AgentId = Agent, ItemId = Item,
		[Id!!Id] = cast(Agent as nvarchar) + N'_' + cast(Item as nvarchar),
		[AgentId!!GroupMarker] = GrpAgent,
		[ItemId!!GroupMarker] = GrpItem,
		[Items!TRepData!Items] = null,
		[Item.Id!TItem!Id] = T.Item, [Item.Name!TItem!Name] = i.[Name],
		[Agent.Id!TAgent!Id] = T.Agent, [Agent.Name!TAgent!Name] = a.[Name]
	from T
		left join app.Items i on T.Item = i.Id
		left join app.Agents a on T.Agent = a.Id
	order by GrpAgent desc, GrpItem desc;

	select [Query!TQuery!Object] = null,
		[Period.From!TPeriod!] = @From, [Period.To!TPeriod!] =@To;
end
go

exec app.[Report.Item.Sales.Load] 99;