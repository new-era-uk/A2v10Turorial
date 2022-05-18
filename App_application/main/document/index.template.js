define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        properties: {
            'TParam.$Url'() { return `/document/${this.Kind}`; },
            'TAgent.$NameCode'() { return `${this.Name} [${this.Code}]`; }
        }
    };
    exports.default = template;
});
