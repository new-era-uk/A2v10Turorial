
const template: Template = {
	properties: {
		'TRepData.$Name'() { return this.$level == 1 ? this.Agent.Name : this.Item.Name; }
	},
	commands: {
		drillDown
	}
} 

export default template;

function drillDown(item) {
	console.dir(item);
	let ctrl: IController = this.$ctrl;
	ctrl.$navigate('/report/byitem/docs', {
		Id: 0, Agent: item.AgentId, Item: item.ItemId,
		From: this.Query.Period.From
	}, true);
}