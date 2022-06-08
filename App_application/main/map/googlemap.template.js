define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        properties: {
            'TRoot.$MapUrl'() {
                return 'https://www.google.com/maps/embed/v1/place?key=@{AppSettings.GoogleMapsApiKey}&q=Downing+street+10,London+England&language=uk&region=UA';
            },
        }
    };
    exports.default = template;
});
