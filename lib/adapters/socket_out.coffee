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
zmq = require "zmq"
validator = require "../validator"
utils = require "../utils"

#
# Class that defines a Socket Outbound Adapter.
# It is the basic writing adapter. Actor automatically add one to communicate.
#
class SocketOutboundAdapter extends OutboundAdapter

  # @property {object} zeromq socket
  sock: undefined

  #
  # Adapter's constructor
  # @param properties {object} Launch properties of the adapter
  #
  constructor: (properties) ->
    super
    @type = "socket_out"
    if properties.url
      @url = properties.url
    else
      throw new Error "You must explicitely pass a valid url to a SocketOutboundAdapter"

  #
  # Initialize socket when starting
  #
  h_initSocket: () ->
    @sock = zmq.socket "push"
    @sock.identity = "SocketOA_of_#{@owner.actor}_to_#{@targetActorAid}"

  #
  # @overload start()
  #   Method which start the adapter.
  #   When this adapter is started, the channel can transmit hMessage
  #
  start: (callback)->
    @h_initSocket()
    @sock.connect @url
    @owner.log "trace", "#{@sock.identity} writing on #{@url}"
    dontWatch = not @owner.tracker or
    @owner.type is "tracker" or # is tracker
    utils.urn.bare(@owner.actor) is @owner.tracker.trackerChannel or # is trackChannel
    @targetActorAid is @owner.tracker.trackerId or # target is tracker
    utils.urn.bare(@targetActorAid) is @owner.tracker.trackerChannel # target is trackChannel
    unless dontWatch
      cb = () ->
        delete @owner.timerOutAdapter[@targetActorAid]
        @destroy()
      @h_watchPeer(@targetActorAid, cb)
    if callback then callback() else @started = true

  #
  # @overload stop()
  #   Method which stop the adapter.
  #   When this adapter is stopped, the actor will not transmit hMessage form this adapter anymore
  #
  stop: ->
    if @started
      if @sock._zmq.state is 0
        @sock.close()
      super
      @sock.on "message", ()=>
      @sock = null
      doUnwatch = @owner.tracker and
      @owner.type isnt "tracker" and
      @owner.actor isnt @owner.tracker.trackerChannel and
      @targetActorAid isnt @owner.tracker.trackerId and
      utils.urn.bare(@targetActorAid) isnt @owner.tracker.trackerChannel
      if doUnwatch
        @h_unwatchPeer(@targetActorAid)
      if @owner.tracker and utils.urn.bare(@targetActorAid) is @owner.tracker.trackerChannel
        index = 0
        for outbound in @owner.outboundAdapters
          if outbound is @
            @owner.outboundAdapters.splice(index, 1)
          index++

  #
  # @overload send(buffer)
  #   Method which send the hMessage in the zmq push socket.
  #   @param buffer {Buffer} The hMessage to send
  #
  send: (buffer) ->
    @start() unless @started
    @sock.send buffer

  #
  # Register adapter as a "watcher" for a peer
  # @private
  # @param actor {string} URN of the peer watched
  # @param cb {function} Function to call when unwatching
  #
  h_watchPeer: (actor, cb) ->
    @owner.h_watchPeer(actor, @, cb)

  #
  # Unregister adapter as a "watcher" for a peer
  # @private
  # @param actor {string} URN of the peer watched
  #
  h_unwatchPeer: (actor) ->
    @owner.h_unwatchPeer(actor, @)

  #
  # Remove adapter from his owner's adapters lists
  #
  destroy: () ->
    @owner.h_removeAdapter(@)


module.exports = SocketOutboundAdapter
