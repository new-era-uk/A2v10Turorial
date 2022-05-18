
const template: Template = {
	properties: {
		'TParam.$Url'() { return `/document/${this.Kind}`; },
		'TAgent.$NameCode'() { return `${this.Name} [${this.Code}]`; }
	}
} 

export default template;