define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        properties: {
            'TRepData.$Name'() { return this.$level == 1 ? this.Agent.Name : this.Item.Name; }
        },
        commands: {
            drillDown
        }
    };
    exports.default = template;
    function drillDown(item) {
        console.dir(item);
        let ctrl = this.$ctrl;
        ctrl.$navigate('/report/byitem/docs', {
            Id: 0, Agent: item.AgentId, Item: item.ItemId,
            From: this.Query.Period.From
        }, true);
    }
});
