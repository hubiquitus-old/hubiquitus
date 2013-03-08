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
{InboundAdapter} = require "./hadapter"
url = require "url"


class HttpInboundAdapter extends InboundAdapter
  constructor: (properties) ->
    super
    if properties.url
      url_props = url.parse(properties.url)
      if url_props.port then @port = url_props.port else @port = 8888
      if url_props.hostname then @serverPath = url_props.hostname else @serverPath = "127.0.0.1"
    else
      throw new Error "You must provide a listening url"

    @qs = require 'querystring'
    @sys = require 'sys'
    @http = require 'http'


  start: ->
    @owner.log "debug", "Server path : #{@serverPath} Port : #{@port} is  running ..."
    server = @http.createServer (req, res) =>
      if req.method is 'POST'
        body = ""
        req.on "data", (data) ->
          body += data
        req.on "end", =>
          post_data =  @qs.parse(body)
          @owner.emit "message", @owner.buildMessage(@owner.actor, "hHttpData", post_data, {headers:req.headers})

      else if req.method is 'GET'
        req.on 'end', -> res.writeHead 200, 'ontent-Type' : 'text/plain'
        res.end()
        url_parts =  @qs.parse(req.url)
        @owner.emit "message", @owner.buildMessage(@owner.actor, "hHttpData", url_parts, {headers:req.headers})

    server.listen @port,@serverPath


exports.HttpInboundAdapter = HttpInboundAdapter
exports.newAdapter = (properties) ->
  new HttpInboundAdapter properties
