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

url = require "url"
zmq = require "zmq"
validator = require "./../validator"

class Adapter

  constructor: (properties) ->
    @started = false
    if properties.owner
      @owner = properties.owner
    else
      throw new Error("You must pass an actor as reference")

  formatUrl: (url_string) ->
    if url_string
      url_props = url.parse(url_string)
      if url_props.port
        @url = url_string
      else
        url_props.port = @genListenPort()
        delete url_props.host
        @url = url.format(url_props)
    else
      @url = "tcp://127.0.0.1:#{@genListenPort}"

  genListenPort: ->
    Math.floor(Math.random() * 30000)+3000

  start: ->
    @started = true

  stop: ->
    @started = false

class InboundAdapter extends Adapter

  constructor: (properties) ->
    @direction = "in"
    super


class SocketInboundAdapter extends InboundAdapter

  constructor: (properties) ->
    super
    @formatUrl(properties.url)
    @type = "socket_in"
    @initSocket()

  initSocket: () ->
    @sock = zmq.socket "pull"
    @sock.identity = "SocketIA_of_#{@owner.actor}"
    @sock.on "message", (data) =>
      @owner.emit "message", JSON.parse(data)

  start: ->
    while @started is false
      try
        @sock.bindSync @url
        @owner.log "debug", "#{@sock.identity} listening on #{@url}"
        super
      catch err
        if err.message is "Address already in use"
          @sock = null
          @initSocket()
          @formatUrl @url.replace(/:[0-9]{4,5}$/, '')
          @owner.log "error", 'Change listening port to avoid collision :',err

  stop: ->
    if @started
      if @sock._zmq.state is 0
        @sock.close()
      super

class LBSocketInboundAdapter extends InboundAdapter

  constructor: (properties) ->
    super
    @formatUrl(properties.url)
    @type = "lb_socket_in"
    @initSocket()

  initSocket: () ->
    @sock = zmq.socket "pull"
    @sock.identity = "LBSocketIA_of_#{@owner.actor}"
    @sock.on "message", (data) =>
      @owner.emit "message", JSON.parse(data)

  start: ->
    while @started is false
      try
        @sock.connect @url
        @owner.log "debug", "#{@sock.identity} listening on #{@url}"
        super
      catch err
        if err.message is "Address already in use"
          @sock = null
          @initSocket()
          @formatUrl @url.replace(/:[0-9]{4,5}$/, '')
          @owner.log "error", 'Change listening port to avoid collision :',err

  stop: ->
    if @started
      if @sock._zmq.state is 0
        @sock.close()
      super

class ChannelInboundAdapter extends InboundAdapter

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
    @sock = zmq.socket "sub"
    @sock.identity = "ChannelIA_of_#{@owner.actor}"
    @sock.on "message", (data) =>
      hMessage = data.toString().replace(/^.*\$/, "")
      hMessage = JSON.parse(hMessage)
      hMessage.actor = @owner.actor
      @owner.emit "message", hMessage

  addFilter: (quickFilter) ->
    @owner.log "debug", "Add quickFilter #{quickFilter} on #{@owner.actor} ChannelIA for #{@channel}"
    @sock.subscribe(quickFilter)
    @listQuickFilter.push quickFilter

  removeFilter: (quickFilter, cb) ->
    @owner.log "debug", "Remove quickFilter #{quickFilter} on #{@owner.actor} ChannelIA for #{@channel}"
    if @sock._zmq.state is 0
      @sock.unsubscribe(quickFilter)
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


class OutboundAdapter extends Adapter

  constructor: (properties) ->
    @direction = "out"
    if properties.targetActorAid
      @targetActorAid = properties.targetActorAid
    else
      throw new Error "You must provide the AID of the targeted actor"
    super

  start: ->
    super

  send: (message) ->
    throw new Error "Send method should be overriden"

class LocalOutboundAdapter extends OutboundAdapter

  constructor: (properties) ->
    super
    if properties.ref
      @ref = properties.ref
    else
      throw new Error("You must explicitely pass an actor as reference to a LocalOutboundAdapter")

  start: ->
    super

  send: (message) ->
    @start() unless @started
    @ref.emit "message", message

class ChildprocessOutboundAdapter extends OutboundAdapter

  constructor: (properties) ->
    super
    if properties.ref
      @ref = properties.ref
    else
      throw new Error("You must explicitely pass an actor child process as reference to a ChildOutboundAdapter")

  start: ->
    super

  stop: ->
    if @started
      @ref.kill()
    super

  send: (message) ->
    @start() unless @started
    @ref.send message

class SocketOutboundAdapter extends OutboundAdapter

  constructor: (properties) ->
    super
    if properties.url
      @url = properties.url
    else
      throw new Error("You must explicitely pass a valid url to a SocketOutboundAdapter")
    @sock = zmq.socket "push"
    @sock.identity = "SocketOA_of_#{@owner.actor}_to_#{@targetActorAid}"

  start:->
    super
    @sock.connect @url
    @owner.log "debug", "#{@sock.identity} writing on #{@url}"


  stop: ->
    if @started
      if @sock._zmq.state is 0
        @sock.close()
      super

  send: (message) ->
    @start() unless @started
    @sock.send JSON.stringify(message)

class LBSocketOutboundAdapter extends OutboundAdapter

  constructor: (properties) ->
    super
    if properties.url
      @url = properties.url
    else
      throw new Error("You must explicitely pass a valid url to a LBSocketOutboundAdapter")
    @sock = zmq.socket "push"
    @sock.identity = "LBSocketOA_of_#{@owner.actor}_to_#{@targetActorAid}"

  start:->

    @sock.bindSync @url
    @owner.log "debug", "#{@sock.identity} bound on #{@url}"
    super

  stop: ->
    if @started
      if @sock._zmq.state is 0
        @sock.close()
      super

  send: (message) ->
    @start() unless @started
    @sock.send JSON.stringify(message)


class ChannelOutboundAdapter extends OutboundAdapter

  constructor: (properties) ->
    properties.targetActorAid = "#{validator.getBareURN(properties.owner.actor)}"
    super
    if properties.url
      url_props = url.parse(properties.url)
      if url_props.port
        @url = properties.url
      else
        url_props.port = @genListenPort()
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
          @owner.log "error", 'Change streaming port to avoid collision :',err

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


class SocketIOAdapter extends OutboundAdapter

  constructor: (properties) ->
    super
    @type = "socketIO"
    @sock = properties.socket
    @sock.identity = "socketIO_of_#{@owner.actor}"
    @sock.on "hMessage", (hMessage) =>
      @owner.emit "message", hMessage

  start: ->
    super

  stop: ->
    super

  send: (hMessage) ->
    @start() unless @started
    @sock.emit "hMessage", hMessage

exports.adapter = (type, properties) ->
  switch type
    when "socket_in"
      new SocketInboundAdapter(properties)
    when "lb_socket_in"
      new LBSocketInboundAdapter(properties)
    when "channel_in"
      new ChannelInboundAdapter(properties)
    when "inproc"
      new LocalOutboundAdapter(properties)
    when "fork"
      new ChildprocessOutboundAdapter(properties)
    when "socket_out"
      new SocketOutboundAdapter(properties)
    when "lb_socket_out"
      new LBSocketOutboundAdapter(properties)
    when "channel_out"
      new ChannelOutboundAdapter(properties)
    when "socketIO"
      new SocketIOAdapter(properties)
    when "timerAdapter"
      timerAdapter = require("./hTimerAdapter")
      timerAdapter.newTimerAdapter(properties)
    when "http_in"
      httpInAdapter = require("./hHttpAdapter")
      httpInAdapter.newHttpInboundAdapter(properties)
    when "http_out"
      httpOutAdapter = require("./hHttpAdapter")
      httpOutAdapter.newHttpOutboundAdapter(properties)
    else
      try
        adapter = require(properties.type)
        adapter.newAdapter(properties)
      catch error
        throw new Error "Incorrect type '#{type}'"

exports.InboundAdapter = InboundAdapter
exports.OutboundAdapter = OutboundAdapter
exports.timerAdapter = require("./hTimerAdapter")
exports.httpInboundAdapter = require("./hHttpAdapter").HttpInboundAdapter
exports.httpOutboundAdapter = require("./hHttpAdapter").HttpOutboundAdapter