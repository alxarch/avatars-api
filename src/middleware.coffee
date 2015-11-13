_ = require "lodash"
# TODO: Add cache-control headers / options
Avatars = require "./avatars"
module.exports = (options) ->
	options = {requestSize, requestId} = _.defaults {}, options,
		requestId: "params.id"
		requestSize: "params.size"

	avatars = new Avatars options

	(req, res, next) ->
		id = _.get req, requestId
		size = _.get req, requestSize
		res.set "Content-Type", "image/png"
		avatars.stream id, size
		.pipe res
		.on "error", next
		.on "finish", ->
			process.nextTick next
