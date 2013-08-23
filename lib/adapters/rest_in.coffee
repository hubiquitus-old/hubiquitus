#
# * Copyright (c) Novedia Group 2012.
# *
# *    This file is part of Hubiquitus
# *
# *    Permission is hereby granted, free of charge, to any person obtaining a copy
# *    of this software and associated documentation files (the "Software"), to deal
# *    in the Software without restriction, including without limitation the rights
# *    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# *    of the Software, and to permit persons to whom the Software is furnished to do so,
# *    subject to the following conditions:
# *
# *    The above copyright notice and this permission notice shall be included in all copies
# *    or substantial portions of the Software.
# *
# *    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# *    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# *    PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
# *    FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# *    ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# *
# *    You should have received a copy of the MIT License along with Hubiquitus.
# *    If not, see <http://opensource.org/licenses/mit-license.php>.
#
InboundAdapter = require "./InboundAdapter"
url = require "url"
validator = require "../validator"
UUID = require "../UUID"

url = require 'url'
http = require 'http'
https = require 'https'
querystring = require 'querystring'
_ = require 'lodash'


#
# Class that defines a rest Inbound Adapter.
# It is used to listen rest requests
#
class RestInboundAdapter extends InboundAdapter

  # @property {string} listening url. Should follow the format (http/https)://(listening ip or * for all ips):(port number). Ex http://*:8888
  url : undefined

  # @property {number} listening port.
  port : undefined

  # @property {string} listening for hostname
  hostname : undefined

  # @property {boolean} should we use secured layer. In this case, security object is needed with a key and a certificate
  https : undefined

  # @property {object} ssl layer certificat and key. Only needed in https
  ssl : undefined

  # @property {object} server object. Should be a nodejs http or https object
  server : undefined

  # @property {number} max content size in bytes. If <0 than unlimited. By default : -1.
  maxContentSize : undefined

  # @property {number} maximum amount a time that can be taken by a query before receiving a timeout (including call + answer). Default 30s
  queryTimeout : undefined

  # @property {object} link a result status to an http response code
  respCode : undefined

  #
  # Adapter's constructor
  # @param properties {object} Launch properties of the adapter
  #
  constructor: (properties) ->
    super

    @respCode = {0:200, 1:500, 5:401, 6:400, 7:400, 8:404, 9:408}

    @port = 8888
    @https = false

    @maxContentSize = -1
    @queryTimeout = 30000

    if properties.maxContentSize >= 0
      @maxContentSize = properties.maxContentSize

    if properties.queryTimeout >= 0
      @queryTimeout = properties.queryTimeout

    if properties.url
      @url = url
      url_props = url.parse(properties.url)
      if typeof url_props.port is "number"
        @port = url_props.port

      if typeof url_props.hostname is "string" and url_props.hostname isnt "*"
        @hostname = url_props.hostname

      if typeof url_props.protocol is "string" and url_props.protocol is "https:"
        @https = true

    if properties.ssl and typeof properties.ssl is "object"
      @ssl.key = properties.ssl.key
      @ssl.cert = properties.ssl.cert

  #
  # @overload start()
  # Method which start the adapter.
  # When this adapter is started, the actor listen for http request
  #
  start: ->
    if @started
      return

    super
    @owner.log "debug", "Rest adapter trying to listen on : " + @url
    options = {}

    if @https
      unless @ssl
        @owner.log "warn", "Tryed to start rest adapter in https mode, but no ssl certificate provided. Stopping adapter"
        return

      options.key = fs.readFileSync(@ssl.key)
      options.cert = fs.readFileSync(@ssl.cert)

      @server = https.createServer(options)
    else
      @server = http.createServer();

    if @hostname
      @server.listen @port, @hostname
    else
      @server.listen @port

    @server.on "request", (request, response) =>
      @handleRequest request, response

  #
  # @overload stop()
  #
  stop: ->
    if @started
      @server.close()
      super

  #
  # Handle an http request to extract data and give an answer
  #
  handleRequest: (request, response) ->
    content = undefined
    metadata = @makeMetadata request

    contentSize = 0
    error = false

    timeoutId = setTimeout () =>
      error = true
      response.statusCode = 408
      response.end()
    , @queryTimeout

    request.on "data", (data) =>
      if error
        return

      if content
        content = Buffer.concat([content, data], content.length + data.length)
      else
        content = data

      contentSize += data.length

      if @maxContentSize > 0 and contentSize > @maxContentSize
        error = true
        response.statusCode = 400

        response.end()
        clearTimeout(timeoutId)
        return

    request.on "end", =>
      if error
        return

      @receive content, metadata, (buffer, metadata) =>
        if metadata.headers
          response.writeHead metadata.statusCode, metadata.headers
        else
          response.statusCode = metadata.statusCode

        if buffer
          response.write buffer

        response.end()
        clearTimeout(timeoutId)

  #
  # Make adapter metadata from request
  # @param request {http.IncomingMessage} http request
  #
  makeMetadata: (request) ->
    metadata = {}

    metadata.method = request.method

    urlComponents = url.parse request.url
    metadata.url = urlComponents.href

    if urlComponents.auth
      metadata.urlAuth = urlComponents.auth

    if urlComponents.pathname
      metadata.pathname = urlComponents.pathname

    if urlComponents.query
      metadata.query = querystring.parse(urlComponents.query)

    metadata.headers = request.headers

    return metadata

  #
  # @overload makeHMessage(data, metadata, callback)
  #
  makeHMessage: (data, metadata, callback) ->
    hMessage = {}
    hMessage.payload = {}
    hMessage.payload.params = {}
    hMessage.type = "hCommand"
    hMessage.payload.cmd = metadata.method
    hMessage.payload.params.service = metadata.pathname
    hMessage.payload.params.content = data
    hMessage.headers = {}
    hMessage.headers.http = metadata.headers
    hMessage.headers.url = metadata.url
    hMessage.actor = @owner.actor
    hMessage.publisher = @owner.actor
    callback null, hMessage

  #
  # @overload makeData(hMessage, callback)
  #
  makeData: (hMessage, callback) ->
    unless hMessage.type is "hResult"
      return callback "Rest adapter response can only be an hResult", null, null

    metadata = {}
    statusCode = 200
    data = undefined

    if hMessage.payload and hMessage.payload.status
      statusCode = @respCode[hMessage.payload.status] or statusCode

    if hMessage.headers
      metadata.headers = hMessage.headers.http
      statusCode = hMessage.headers.httpStatusCode or statusCode

    metadata.statusCode = statusCode

    if hMessage.payload and hMessage.payload.result
      data = hMessage.payload.result

    callback null, data, metadata

module.exports = RestInboundAdapter
