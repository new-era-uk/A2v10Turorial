// item.server.api

module.exports = function (prms, args) {
	const dm = this.loadModel({
		procedure: "app.[Agent.Index]",
		parameters: {
			UserId: prms.UserId
		}
	});
	return dm.Agents;
};