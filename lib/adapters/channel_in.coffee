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
{InboundAdapter} = require "./InboundAdapter"
zmq = require "zmq"
validator = require "../validator"
codes = require "../codes"

#
# Class that defines a Channel Inbound Adapter.
# It is used when a actor subscribe to a channel
#
class ChannelInboundAdapter extends InboundAdapter

  # @property {object} zeromq socket
  sock: undefined

  # @property {array} filters apply to the channel (like topics)
  listQuickFilter: undefined

  # @property {string} URN of the channel follow by the adapter
  channel: undefined

  # @property {string} quickFilter to apply when creating the adapter
  filter: undefined

  #
  # Adapter's constructor
  # @param properties {object} Launch properties of the adapter
  #
  constructor: (properties) ->
    super
    @channel = properties.channel
    if properties.url
      @url = properties.url
    else
      throw new Error("You must provide a channel url")
    @type = "channel_in"
    @listQuickFilter = []
    @filter = properties.filter or ""

  #
  # Initialize socket when starting
  #
  h_initSocket: () ->
    @sock = zmq.socket "sub"
    @sock.identity = "ChannelIA_of_#{@owner.actor}"
    @sock.on "message", @receive

  #
  # @overload h_fillMessage()
  #
  h_fillMessage: (hMessage, callback) ->
    hMessage.actor = @owner.actor
    super

  #
  # Mathod called to add a quickFilter in a subscription.
  # Add a quickFilter is like follow a specific topic in a channel
  # @param quickFilter {string} QuickFilter to add
  #
  addFilter: (quickFilter) ->
    @owner.log "debug", "Add quickFilter #{quickFilter} on #{@owner.actor} ChannelIA for #{@channel}"
    @sock.subscribe quickFilter
    @listQuickFilter.push quickFilter

  #
  # Mathod called to remove a quickFilter in a subscription.
  # Remove a quickFilter is like unfollow a specific topic in a channel.
  # If you remove all the quickFilter of a channel, you will be unsubscribe from it
  # @param quickFilter {string} QuickFilter to add
  # @param cb {function} Callback called to inform the actor if there are still a quickFilter in the channel after this remove.
  # @option cb result {boolean} True if there are not a quickFilter anymore, False if there are still one or more
  #
  removeFilter: (quickFilter, cb) ->
    @owner.log "debug", "Remove quickFilter #{quickFilter} on #{@owner.actor} ChannelIA for #{@channel}"
    if @sock._zmq.state is 0
      @sock.unsubscribe quickFilter
    index = 0
    for qckFilter in @listQuickFilter
      if qckFilter is quickFilter
        @listQuickFilter.splice(index, 1)
      index++
    if @listQuickFilter.length is 0
      cb true
    else
      cb false

  #
  # @overload start()
  #   Method which start the adapter.
  #   When this adapter is started, the actor will receive hMessage publish on the channel
  #
  start: ->
    unless @started
      @h_initSocket()
      @sock.connect @url
      @addFilter(@filter)
      @owner.log "debug", "#{@owner.actor} subscribe to #{@channel} on #{@url}"
      super
      dontWatch = not @owner.trackers[0] or
      @owner.type is "tracker" or # actor is tracker
      validator.getBareURN(@owner.actor) is @owner.trackers[0].trackerChannel or # actor is trackChannel
      validator.getBareURN(@channel) is @owner.trackers[0].trackerChannel # links to trackChannel
      unless dontWatch
        cb = () ->
          index = 0
          for subscription in @owner.subscriptions
            if validator.getBareURN(subscription) is @channel
              @owner.subscriptions.splice(index, 1)
            index++
          adapterProps = new Object()
          adapterProps.channel = @channel
          unless @dontRetryToSub
            @owner.subscribe adapterProps.channel, (status, result) =>
              unless status is codes.hResultStatus.OK
                @owner.log "debug", "Resubscription to #{adapterProps.channel} failed cause #{result}"
                ## TODO Call UUID.generate
                errorID = @owner.h_makeMsgId()
                @owner.raiseError(errorID, "Resubscription to #{adapterProps.channel} failed")
                @owner.h_autoSubscribe(adapterProps, 500, errorID)
          @destroy()
        @h_watchPeer(@channel, cb)

  #
  # @overload stop()
  #   Method which stop the adapter.
  #   When this adapter is stopped, the actor will not receive hMessage publish on the channel anymore
  #
  stop: (dontRetryToSubscribe) ->
    @dontRetryToSub = dontRetryToSubscribe
    if @started
      if @sock._zmq.state is 0
        @sock.close()
      super
      @sock.on "message", () =>
      @sock = null
      doUnwatch = @owner.trackers[0] and
      @owner.type isnt "tracker" and
      validator.getBareURN(@owner.actor) isnt @owner.trackers[0].trackerChannel and
      validator.getBareURN(@channel) isnt @owner.trackers[0].trackerChannel # is not trackChannel
      if doUnwatch
        @h_unwatchPeer @channel
      index = 0
      for subscription in @owner.subscriptions
        if validator.getBareURN(subscription) is @channel
          break
        index++
      @owner.subscriptions.splice(index, 1)
      if @owner.trackers[0] and validator.getBareURN(@channel) is @owner.trackers[0].trackerChannel
        index = 0
        for inbound in @owner.inboundAdapters
          if inbound is @
            @owner.inboundAdapters.splice(index, 1)
          index++


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

module.exports = ChannelInboundAdapter
