Promise = require "bluebird"
fs = require "fs"
_path = require "path"
readdir = Promise.promisify fs.readdir
gm = require "gm"
imageMagick = gm.subClass imageMagick: yes
_ = require "lodash"
pull = (arr, i) -> arr[i % (arr.length - 1)]

defaultColors = [
	"#81bef1"
	"#ad8bf2"
	"#bff288"
	"#de7878"
	"#a5aac5"
	"#6ff2c5"
	"#f0da5e"
	"#eb5972"
	"#f6be5d"
	]

class PotatoAvatars
	module.exports = @
	constructor: (options) ->
		@options = _.defaults {}, options,
			assets: _path.resolve __dirname, "../assets"
			types: ["eyes", "mouth", "nose"]
			colors: defaultColors
			minSize: 40
			maxSize: 400
			hashingFn: (sum, n, i) -> if i % 2 then n + i else n - i
			cacheDir: null
		@assets = {}
		for type in @options.types
			@assets[type] = []
		@colors = @options.colors
		@loadAssets @options.assets

	loadAssets: (dir) ->
		{types} = @options
		Promise.all types.map (type) -> readdir "#{dir}/#{type}"
		.map (files, i) ->
			path = "#{dir}/#{types[i]}"
			for file in files when file.match /\.png$/
				"#{path}/#{file}"
		.map (assets, i) =>
			type = types[i]
			@assets[type] = @assets[type].concat assets

	index: (string) ->
		buffer = new Buffer @identifier string
		pos = Array::reduce.call buffer, @options.hashingFn, 0
		buffer.length + Math.abs pos

	face: (string) ->
		i = @index string
		face = color: pull @colors, i
		for type in @options.types
			face[type] = pull @assets[type], i
		face

	parseSize: (size) ->
		size ?= @options.maxSize
		[width, height] = "#{size}".split "x"
		width = +width
		height = +height
		if +width
			height = height or width
			width: Math.min (Math.max width, @options.minSize), @options.maxSize
			height: Math.min (Math.max height, @options.minSize), @options.maxSize
		else
			width: @options.maxSize
			height: @options.maxSize

	combine: (face, size=null) ->
		{width, height} = @parseSize size
		img = imageMagick()
		for type in @options.types
			img.in face[type]
		img
			.background(face.color)
			.mosaic()
			.resize(width, height)
			.gravity("Center")
			.extent(width, height)
			.stream("png")

	stream: (identifier, size) -> @combine @face(identifier), size

	identifier: (string) -> "#{string}".replace /\.(png|jpe?g|gif)$/, ""
