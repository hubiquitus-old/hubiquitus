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
{OutboundAdapter} = require "./OutboundAdapter"
url = require "url"
validator = require "../validator"
#
# Class that defines a http Outbound Adapter.
# It is used to write http request on a server
#
class HttpOutboundAdapter extends OutboundAdapter

  #
  # Adapter's constructor
  # @param properties {object} Launch properties of the adapter
  #
  constructor: (properties) ->
    super
    if properties.url
      url_props = url.parse(properties.url)
      if url_props.hostname then @server_url = url_props.hostname else @server_url = "127.0.0.1"
    else
      throw new Error "You must provide a writing url"

    if properties.port then @port = properties.port else @port = 8888

    if properties.path then @path = properties.path else @path = "/"

    @owner.log "debug", "HttpOutboundAdapter used -> [ url: #{@server_url} port : #{@port} path: #{@path} ]"

  #
  # @overload h_send(buffer)
  #   Method which send the hMessage in the zmq push socket.
  #   @param buffer {Buffer} The hMessage to send
  #
  h_send: (buffer) ->
    @start() unless @started

    @querystring = require 'querystring'
    @http = require 'http'
    @reqst = require 'request'

    post_options =
      url: url.format {protocol: 'http:', hostname: @server_url, port: @port, pathname: @path}
      method: 'POST'
      headers:
        "Content-Type": "application/x-www-form-urlencoded"
        "Content-Length": buffer.length
      body: buffer

    @reqst post_options, (err, res) =>
      if err
        @owner.log "warn", "problem with request: " + err


module.exports = HttpOutboundAdapter
