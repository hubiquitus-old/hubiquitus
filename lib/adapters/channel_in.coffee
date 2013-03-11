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
zmq = require "zmq"


class ChannelInboundAdapter extends InboundAdapter

 # @property {object} zeromq socket
  sock: undefined

  # @property {array} filters
  listQuickFilter: undefined

  constructor: (properties) ->
    @channel = properties.channel
    super
    if properties.url
      @url = properties.url
    else
      throw new Error("You must provide a channel url")
    @type = "channel_in"
    @listQuickFilter = []
    @filter = properties.filter or ""

  initSocket: () ->
    @sock = zmq.socket "sub"
    @sock.identity = "ChannelIA_of_#{@owner.actor}"
    @sock.on "message", (data) =>
      splitString = data.toString().replace(/^[^{]*\$?{/, "{")
      splitData = new Buffer(splitString)
      cleanData = data.slice(data.length - splitData.length, data.length)
      hMessage = JSON.parse(cleanData)
      hMessage.actor = @owner.actor
      @owner.emit "message", hMessage

  addFilter: (quickFilter) ->
    @owner.log "debug", "Add quickFilter #{quickFilter} on #{@owner.actor} ChannelIA for #{@channel}"
    @sock.subscribe quickFilter
    @listQuickFilter.push quickFilter

  removeFilter: (quickFilter, cb) ->
    @owner.log "debug", "Remove quickFilter #{quickFilter} on #{@owner.actor} ChannelIA for #{@channel}"
    if @sock._zmq.state is 0
      @sock.unsubscribe quickFilter
    index = 0
    for qckFilter in @listQuickFilter
      if qckFilter is quickFilter
        @listQuickFilter.splice(index,1)
      index++
    if @listQuickFilter.length is 0
      cb true
    else
      cb false

  start: ->
    @initSocket()
    unless @started
      @sock.connect @url
      @addFilter(@filter)
      @owner.log "debug", "#{@owner.actor} subscribe to #{@channel} on #{@url}"
      super

  stop: ->
    if @started
      if @sock._zmq.state is 0
        @sock.close()
      super
      @sock.on "message",()=>
      @sock=null


exports.ChannelInboundAdapter = ChannelInboundAdapter
exports.newAdapter = (properties) ->
  new ChannelInboundAdapter properties
