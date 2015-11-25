_ = require "lodash"
Promise = require "bluebird"
_path = require "path"
fs = require "fs"
os = require "os"
mkdirp = Promise.promisify require "mkdirp"

# TODO: Add cache-control headers / options
Avatars = require "./avatars"
module.exports = (options) ->
	options = {requestSize, requestId} = _.defaults {}, options,
		requestId: "params.id"
		requestSize: "params.size"
		cacheDir: _path.join os.tmpdir(), "potato-avatars-cache"

	avatars = new Avatars options

	(req, res, next) ->
		id = _.get req, requestId
		size = _.get req, requestSize
		cacheFile = _path.join options.cacheDir, (size or ""), "#{avatars.identifier id}.png"
		mkdirp _path.dirname cacheFile
		.then ->
			Promise.all [
				Promise.try -> avatars.stream id, size
				Promise.try -> fs.createWriteStream cacheFile
			]
		.then ([avatar, cache]) ->
			new Promise (resolve, reject) ->
				cache.on "error", reject
				avatar.pipe cache
				res.set "Content-Type", "image/png"
				avatar.pipe res
				.on "error", reject
				.on "finish", -> resolve()
		.then -> next()
		.catch next
