
const utilsDate: UtilsDate = require('std:utils').date;

const template: Template = {
	properties: {
		'TRow.Sum'() { return this.Price * this.Qty; },
		'TDocument.Sum'() { return this.Rows.reduce((p, c) => p + c.Sum, 0); },
	},
	defaults: {
		'Document.Date'() { return utilsDate.today(); }
	}
} 

export default template;