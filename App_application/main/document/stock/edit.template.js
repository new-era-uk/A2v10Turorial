define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const utilsDate = require('std:utils').date;
    const template = {
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
    };
    exports.default = template;
    async function apply(doc) {
        const ctrl = this.$ctrl;
        await ctrl.$invoke('apply', { Id: doc.Id }, '/document');
        await ctrl.$requery();
    }
    async function unapply(doc) {
        const ctrl = this.$ctrl;
        await ctrl.$invoke('unapply', { Id: doc.Id }, '/document');
        await ctrl.$requery();
    }
});
