_ = require "lodash"
Promise = require "bluebird"
_path = require "path"
fs = require "fs"
os = require "os"
mkdirp = (path) ->
	Promise.reduce path.split(_path.sep), (result, part) ->
		result = _path.join result, part
		new Promise (resolve, reject) ->
			fs.mkdir result, (err) ->
				if err and err.code isnt "EEXIST"
					reject err
				else
					resolve result
	, ''

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
		.then -> Promise.all [
			Promise.try -> avatars.stream id, size
			Promise.try -> fs.createWriteStream cacheFile
		]
		.then ([avatar, cache]) ->
			new Promise (resolve, reject) ->
				avatar.pipe cache
				res.set "Content-Type", "image/png"
				avatar.pipe res
				.on "error", reject
				.on "finish", -> resolve()
		.then -> next()
		.catch next
