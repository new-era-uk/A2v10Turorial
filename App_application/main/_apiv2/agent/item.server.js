// item.server.api

module.exports = function (prms, args) {
	const dm = this.loadModel({
		procedure: "app.[Agent.Load]",
		parameters: {
			UserId: prms.UserId,
			Id: args.body.AgentId
		}
	});
	return dm.Agent;
};