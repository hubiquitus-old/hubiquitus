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
zmq = require "zmq"
validator = require "./../validator"


class ChannelOutboundAdapter extends OutboundAdapter

  # @property {object} zeromq socket
  sock: undefined

  constructor: (properties) ->
    properties.targetActorAid = "#{validator.getBareURN(properties.owner.actor)}"
    super
    if properties.url
      url_props = url.parse(properties.url)
      if url_props.port
        @url = properties.url
      else
        url_props.port = @genListenPort()
        delete url_props.host
        @url = url.format(url_props)
    else
      @url = "tcp://127.0.0.1:#{@genListenPort}"
    @initSocket()

  initSocket: () ->
    @sock = zmq.socket "pub"
    @sock.identity = "ChannelOA_of_#{@owner.actor}"

  start:->
    while @started is false
      try
        @sock.bindSync @url
        @owner.log "debug", "#{@sock.identity} streaming on #{@url}"
        super
      catch err
        if err.message is "Address already in use"
          @sock = null
          @initSocket()
          @formatUrl @url.replace(/:[0-9]{4,5}$/, '')
          @owner.log "info", 'Change streaming port to avoid collision :',err

  stop: ->
    if @started
      if @sock._zmq.state is 0
        @sock.close()
      super

  send: (hMessage) ->
    @start() unless @started
    if hMessage.headers and hMessage.headers.h_quickFilter and typeof hMessage.headers.h_quickFilter is "string"
      message = hMessage.headers.h_quickFilter+"$"+JSON.stringify(hMessage)
      @sock.send message
    else
      @sock.send JSON.stringify(hMessage)


exports.ChannelOutboundAdapter = ChannelOutboundAdapter
exports.newAdapter = (properties) ->
  new ChannelOutboundAdapter properties
