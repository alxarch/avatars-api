# node packages
http     = require('http')
express  = require('express')
path     = require('path')
colors   = require('colors')

# configuration
app           = express()
webserver     = http.createServer(app)
basePath      = __dirname
generatedPath = path.join(basePath, '.generated')
vendorPath    = path.join(basePath, 'bower_components')

# Configure the express server
app.engine('.html', require('ejs').__express)
app.use('/avatar', require('./lib/routes/v1'))
app.use('/avatars', require('./lib/routes/v2'))
app.use('/assets', express.static(generatedPath))
app.use('/vendor', express.static(vendorPath))

module.exports = app

if require.main is module

	port = process.env.PORT or 3002
	findPort = require('find-port')

	# Find an available port
	if port > 3002
	  webserver.listen(port)
	else
	findPort port, port + 100, (ports) ->
		# Notify the console that we're connected and on what port
		webserver.on 'listening', ->
		  address = webserver.address()
		  console.log "[Firepit] Server running at http://#{address.address}:#{address.port}".green
		webserver.listen(ports[0])
