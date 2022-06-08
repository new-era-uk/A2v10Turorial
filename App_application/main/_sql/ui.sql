-- application ui

-----------------------------------------------
-- main menu
begin
	set nocount on;

	if not exists (select * from a2security.Acl where [Object] = N'std:menu' and ObjectId = 1 and GroupId = 1)
		insert into a2security.[Acl] ([Object], [ObjectId], GroupId, CanView) values (N'std:menu', 1, 1, 1);

	declare @menu a2ui.[Menu2.TableType];
	insert into @menu(Id, Parent, [Order], [Name], [Url], Icon) values
	(1, null, 0, N'ROOT', null, null),
	(10,   1, 1, N'Catalog', N'catalog', null),
	(20,   1, 2, N'Document', N'document', null),
	(30,   1, 3, N'Report',  N'report', null),
	(40,   1, 3, N'Maps',    N'map', null),
	(101, 10, 1, N'Agents',  N'agent', N'users'),
	(102, 10, 2, N'Items',    N'item',  N'package-outline'),
	(103, 10, 3, N'Banks',    N'bank',  N'currency-uah'),
	(201, 20, 1, N'Waybill In',    N'waybillin',  N'file'),
	(202, 20, 1, N'Waybill Out',   N'waybillout',  N'file'),
	(301, 30, 1, N'By Item',   N'byitem',  N'report');

	exec a2ui.[Menu.Merge] @menu, 1, 1000;

	exec [a2security].[Permission.UpdateAcl.Menu];
end
go

if not exists(select * from a2security.ApiUserLogins)
begin
	insert into a2security.ApiUserLogins ([User], [Mode], ApiKey)
	values (99, N'ApiKey', N'GFtykJu0N23RauorKTYCMZs3ezJb2dsfenQ5vvhtlyIiDcpuWNi/kdtP0hxw1v')
end
go

