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
			colors: defaultColors
			minSize: 40
			maxSize: 400
			hashingFn: (sum, n, i) -> if i % 2 then n + i else n - i
		@eyes = []
		@mouth = []
		@nose = []
		@colors = @options.colors
		@loadAssets @options.assets

	loadAssets: (dir) ->
		Promise.all [
			readdir "#{dir}/eyes"
			readdir "#{dir}/mouth"
			readdir "#{dir}/nose"
		]
		.map (files, i) ->
			path = "#{dir}/#{['eyes', 'mouth', 'nose'][i]}"
			for file in files when file.match /\.png$/
				"#{path}/#{file}"
		.then ([eyes, mouth, nose]) =>
			@eyes = @eyes.concat eyes
			@mouth = @mouth.concat mouth
			@nose = @nose.concat nose

	index: (string) ->
		buffer = new Buffer _path.basename(string).replace(/\.(png|jpe?g|gif)/g, "")
		pos = Array::reduce.call buffer, @options.hashingFn, 0
		buffer.length + Math.abs pos

	face: (string) ->
		i = @index string
		color: pull @colors, i
		eyes: pull @eyes, i
		nose: pull @nose, i
		mouth: pull @mouth, i

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
		imageMagick()
			.in(face.eyes)
			.in(face.nose)
			.in(face.mouth)
			.background(face.color)
			.mosaic()
			.resize(width, height)
			.trim()
			.gravity('Center')
			.extent(width, height)
			.stream('png')

	stream: (identifier, size) -> @combine @face(identifier), size
