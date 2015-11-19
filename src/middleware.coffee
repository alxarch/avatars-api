_ = require "lodash"
_path = require "path"
fs = require "fs"
# TODO: Add cache-control headers / options
Avatars = require "./avatars"
module.exports = (options) ->
	options = {requestSize, requestId} = _.defaults {}, options,
		requestId: "params.id"
		requestSize: "params.size"
		cacheDir: null

	avatars = new Avatars options

	(req, res, next) ->
		id = _.get req, requestId
		size = _.get req, requestSize
		avatar = avatars.stream id, size
		if options.cacheDir
			cacheFile = _path.join options.cacheDir, (size or ""), "#{avatars.identifier id}.png"
			cache = fs.createWriteStream cacheFile
			avatar.pipe cache

		res.set "Content-Type", "image/png"
		avatar.pipe res
		.on "error", next
		.on "finish", -> next()
