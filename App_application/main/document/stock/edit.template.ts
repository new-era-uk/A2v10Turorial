
const utilsDate: UtilsDate = require('std:utils').date;

const template: Template = {
	properties: {
		'TRow.Sum'() { return this.Price * this.Qty; },
		'TDocument.Sum'() { return this.Rows.reduce((p, c) => p + c.Sum, 0); },
	},
	validators: {
		'Document.Rows[].Qty': 'Enter qty',
		'Document.Rows[].Price': 'Enter price',
	},
	defaults: {
		'Document.Date'() { return utilsDate.today(); }
	},
	commands: {
		apply: {
			exec: apply,
			confirm: 'Are you sure?'
		},
		unapply: {
			exec: unapply,
			confirm: 'Are you sure?'
		}
	}
} 

export default template;

async function apply(doc) {
	const ctrl: IController = this.$ctrl;
	await ctrl.$invoke('apply', { Id: doc.Id }, '/document');
	ctrl.$requery();
}

async function unapply(doc) {
	const ctrl: IController = this.$ctrl;
	await ctrl.$invoke('unapply', { Id: doc.Id }, '/document');
	ctrl.$requery();
}