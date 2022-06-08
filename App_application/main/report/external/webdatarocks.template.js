
/* https://www.webdatarocks.com */

const template = {
	events: {
		"Model.load": modelLoad
	},
	properties: {},
	commands: {}
};

module.exports = template;


function modelLoad() {

	let sales = this.Sales.map(x => {
		let r = {};
		r["Контрагент"] = x.AgentName;
		r["Товар"] = x.ItemName;
		r["Кол-во"] = x.Qty;
		r["Сума"] = x.Sum;
		r["Дата"] = x.Date;
		return r;
	});

	var pivot = new WebDataRocks({
		container: "#wdr-component",
		toolbar: true,
		report: {
			dataSource: {
				data: sales
			}
		}
	});
}

