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
{OutboundAdapter} = require "./hadapter"
url = require "url"


class HttpOutboundAdapter extends OutboundAdapter
  constructor: (properties) ->
    super

    if properties.url
      url_props = url.parse(properties.url)
      if url_props.port then @port = url_props.port else @port = 8888
      if url_props.hostname then @server_url = url_props.hostname else @server_url = "127.0.0.1"
      if properties.path then @path = properties.path else @path = "/"
    else
      throw new Error "You must provide a writing url"

    @owner.log "debug", "HttpOutboundAdapter used -> [ url: #{@server_url} port : #{@port} path: #{@path} ]"

  send: (message) ->
    @start() unless @started

    @querystring = require 'querystring'
    @http = require 'http'

    # Setting the configuration
    post_options =
      host: @server_url
      port: @port
      path: @path
      method: "POST"
      headers:
        "Content-Type": "application/x-www-form-urlencoded"
        "Content-Length": JSON.stringify(message.payload).length

    post_req = @http.request post_options, (res) =>

    post_req.on "error", (e) ->
      @owner.log "warn", "problem with request: " + e.message

    # write parameters to post body
    post_req.write JSON.stringify(message.payload)
    post_req.end()


module.exports = HttpOutboundAdapter
