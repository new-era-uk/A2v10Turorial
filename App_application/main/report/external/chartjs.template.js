/* https://www.chartjs.org */

const du = require('std:utils').date;

const template = {
	events: {
		"Model.load": modelLoad
	},
	properties: {},
	commands: {}
};

module.exports = template;


function modelLoad() {



	const labels = this.Sales.map(x => du.format(x.Date));

	const data = {
		labels: labels,
		datasets: [{
			label: 'Sales (Qty)',
			backgroundColor: 'rgb(255, 99, 132)',
			borderColor: 'rgb(255, 99, 132)',
			data: this.Sales.map(x => x.Qty),
		}]
	};

	const config = {
		type: 'line',
		data: data,
		options: {}
	};

	const myChart = new Chart(
		document.getElementById('canvas'),
		config
	);
}

