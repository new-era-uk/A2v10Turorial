define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        commands: {
            download
        }
    };
    exports.default = template;
    async function download() {
        const ctrl = this.$ctrl;
        let result = await ctrl.$invoke('downloadBanks');
        if (result.success) {
            ctrl.$msg('Завантажено: ' + result.Loaded, "info");
            await ctrl.$reload();
        }
        else {
            alert(result.error);
        }
    }
});
