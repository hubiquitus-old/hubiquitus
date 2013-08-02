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
OutboundAdapter = require "./OutboundAdapter"
url = require "url"
zmq = require "zmq"
validator = require "./../validator"

#
# Class that defines a Channel Outbound Adapter.
# It is used by a channel to publish hMessage
#
class ChannelOutboundAdapter extends OutboundAdapter

  # @property {object} zeromq socket
  sock: undefined

  #
  # Adapter's constructor
  # @param properties {object} Launch properties of the adapter
  #
  constructor: (properties) ->
    super
    @type = "channel_out"
    @formatUrl(properties.url)

  #
  # Method which initialize the zmq pub socket
  #
  initSocket: () ->
    @sock = zmq.socket "pub"
    @sock.identity = "ChannelOA_of_#{@owner.actor}"

  #
  # @overload start()
  #   Method which start the adapter.
  #   When this adapter is started, the channel can transmit hMessage to its subscriber
  #
  start: ->
    @initSocket()
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
          @owner.log "info", 'Change streaming port to avoid collision :', err

  #
  # @overload stop()
  #   Method which stop the adapter.
  #   When this adapter is stopped, the channel cannot publish hMessage anymore
  #
  stop: ->
    if @started
      if @sock._zmq.state is 0
        @sock.close()
      super
      @sock.on "message", ()=>
      @sock = null

  #
  # @overload makeData(hMessage, callback)
  #
  makeData: (hMessage, callback) ->
    metadata = null
    if hMessage and typeof hMessage is "object" and hMessage.headers and typeof hMessage.headers is "object" and hMessage.headers.h_quickFilter
      metadata = {zmqFilter: hMessage.headers.h_quickFilter}

    callback null, hMessage, metadata

  #
  # @overload h_send(buffer, metadata)
  #   Method which send the hMessage in the zmq pub socket.
  #   @param buffer {Buffer} The hMessage to send
  #
  h_send: (buffer, metadata) ->
    @start() unless @started

    try
      zmqFilterEndBuf = new Buffer(1)
      zmqFilterEndBuf[0] = 7
      outBuffer = Buffer.concat([zmqFilterEndBuf, buffer], zmqFilterEndBuf.length + buffer.length)

      if metadata and typeof metadata is "object" and metadata.zmqFilter
        zmqFilterBuf = new Buffer(metadata.zmqFilter, "utf-8")
        outBuffer = Buffer.concat([zmqFilterBuf, outBuffer], zmqFilterBuf.length + outBuffer.length)

      @sock.send outBuffer
    catch err
      @owner.log "error", "channel_out couldn't send a message : " + err


module.exports = ChannelOutboundAdapter
