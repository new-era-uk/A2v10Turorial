define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const utilsDate = require('std:utils').date;
    const template = {
        properties: {
            'TRow.Sum'() { return this.Price * this.Qty; },
            'TDocument.Sum'() { return this.Rows.reduce((p, c) => p + c.Sum, 0); },
        },
        defaults: {
            'Document.Date'() { return utilsDate.today(); }
        }
    };
    exports.default = template;
});
