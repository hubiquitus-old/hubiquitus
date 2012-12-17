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
validator = require "./validator"

class Adapter

  constructor: (properties) ->
    @started = false
    if properties.owner
    then @owner = properties.owner
    else throw new Error("You must pass an actor as reference")

  start: ->
    @started = true

  stop: ->
    @started = false

class InboundAdapter extends Adapter

  constructor: (properties) ->
    super

  genListenPort: ->
    Math.floor(Math.random() * 98)+3000

class SocketInboundAdapter extends InboundAdapter

  constructor: (properties) ->
    super
    if properties.url then @url = properties.url else @url = "tcp://127.0.0.1:#{@genListenPort}"
    @type = "socket"
    @sock = zmq.socket "pull"
    @sock.identity = "SocketIA_of_#{@owner.actor}"
    @sock.on "message", (data) =>
      @owner.emit "message", JSON.parse(data)

  start: ->
    unless @started
      @sock.bindSync @url
      @owner.log "debug", "#{@sock.identity} listening on #{@url}"
      super

  stop: ->
    if @started
      @sock.close()
      super

class LBSocketInboundAdapter extends InboundAdapter

  constructor: (properties) ->
    super
    if properties.url then @url = properties.url else @url = "tcp://127.0.0.1:#{@genListenPort}"
    @type = "lb_socket"
    @sock = zmq.socket "pull"
    @sock.identity = "LBSocketIA_of_#{@owner.actor}"
    @sock.on "message", (data) => @owner.emit "message", JSON.parse(data)

  start: ->
    unless @started
      @sock.connect @url
      @owner.log "debug", "#{@sock.identity} listening on #{@url}"
      super

  stop: ->
    if @started
      @sock.close()
      super

class ChannelInboundAdapter extends InboundAdapter

  constructor: (properties) ->
    super
    if properties.url
    then @url = properties.url
    else throw new Error("You must provide a channel url")
    @type = "channel"
    @sock = zmq.socket "sub"
    @sock.identity = "ChannelIA_of_#{@owner.actor}"
    @sock.on "message", (data) => @owner.emit "message", JSON.parse(data)

  start: ->
    unless @started
      @sock.connect @url
      @sock.subscribe("")
      @owner.log "debug", "#{@sock.identity} subscribe on #{@url}"
      super

  stop: ->
    if @started
      @sock.close()
      super

class OutboundAdapter extends Adapter

  constructor: (properties) ->
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
    then @ref = properties.ref
    else throw new Error("You must explicitely pass an actor as reference to a LocalOutboundAdapter")

  start: ->
    super

  send: (message) ->
    @start() unless @started
    @ref.emit "message", message

class ChildprocessOutboundAdapter extends OutboundAdapter

  constructor: (properties) ->
    super
    if properties.ref
    then @ref = properties.ref
    else throw new Error("You must explicitely pass an actor child process as reference to a ChildOutboundAdapter")

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
    then @url = properties.url
    else throw new Error("You must explicitely pass a valid url to a SocketOutboundAdapter")
    @sock = zmq.socket "push"
    @sock.identity = "SocketOA_of_#{@owner.actor}_to_#{@targetActorAid}"

  start:->
    super
    @sock.connect @url
    @owner.log "debug", "#{@sock.identity} writing on #{@url}"


  stop: ->
    if @started
      @sock.close()

  send: (message) ->
    @start() unless @started
    @sock.send JSON.stringify(message)

class LBSocketOutboundAdapter extends OutboundAdapter

  constructor: (properties) ->
    super
    if properties.url
    then @url = properties.url
    else throw new Error("You must explicitely pass a valid url to a LBSocketOutboundAdapter")
    @sock = zmq.socket "push"
    @sock.identity = "LBSocketOA_of_#{@owner.actor}_to_#{@targetActorAid}"

  start:->

    @sock.bindSync @url
    @owner.log "debug", "#{@sock.identity} bound on #{@url}"
    super

  stop: ->
    if @started
      @sock.close()

  send: (message) ->
    @start() unless @started
    @sock.send JSON.stringify(message)


class ChannelOutboundAdapter extends OutboundAdapter

  constructor: (properties) ->
    properties.targetActorAid = "#{validator.getBareJID(properties.owner.actor)}#subscribers"
    super
    if properties.url
    then @url = properties.url
    else throw new Error("You must explicitely pass a valid url to a ChannelOutboundAdapter")
    @sock = zmq.socket "pub"
    @sock.identity = "ChannelOA_of_#{@owner.actor}"

  start:->
    @sock.bindSync @url
    @owner.log "debug", "#{@sock.identity} streaming on #{@url}"
    super

  stop: ->
    if @started
      @sock.close()

  send: (message) ->
    @start() unless @started
    @sock.send JSON.stringify(message)

exports.inboundAdapter = (type, properties) ->
  switch type
    when "socket"
      new SocketInboundAdapter(properties)
    when "lb_socket"
      new LBSocketInboundAdapter(properties)
    when "channel"
      new ChannelInboundAdapter(properties)
    else
      throw new Error "Incorrect type '#{type}'"

exports.outboundAdapter = (type, properties) ->

  switch type
    when "inproc"
      new LocalOutboundAdapter(properties)
    when "fork"
      new ChildprocessOutboundAdapter(properties)
    when "socket"
      new SocketOutboundAdapter(properties)
    when "lb_socket"
      new LBSocketOutboundAdapter(properties)
    when "channel"
      new ChannelOutboundAdapter(properties)
    else
      throw new Error "Incorrect type '#{type}'"

exports.OutboundAdapter = OutboundAdapter