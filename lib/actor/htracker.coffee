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

{Actor} = require "./hactor"
adapters = require "./../adapters"
_ = require "underscore"
codes = require("./../codes.coffee").hResultStatus
validator = require "./../validator.coffee"

class Tracker extends Actor

  constructor: (properties) ->
    super
    #TODO check properties
    @peers = []
    #@on "started", -> @pingChannel(properties.broadcastUrl)

  onMessage: (message) ->
    @log "debug", "Tracker received a message: #{JSON.stringify(message)}"
    if message.type is "peer-info"
      existPeer = false
      _.forEach @peers, (peers) =>
        if peers.peerFullId is message.publisher
          existPeer = true
          peers.peerStatus = message.payload.peerStatus
          peers.peerInbox = message.payload.peerInbox

      if existPeer isnt true
        @peers.push {peerType:message.payload.peerType, peerFullId:message.publisher, peerId:message.payload.peerId, peerStatus:message.payload.peerStatus, peerInbox:message.payload.peerInbox}
        outbox = @findOutbox(message.publisher)
        if outbox
          @outboundAdapters.push adapters.outboundAdapter(outbox.type, { targetActorAid: outbox.targetActorAid, owner: @, url: outbox.url })

    else if message.type is "peer-search"
      # TODO reflexion sur le lookup et implementation
      outboundadapter = @findOutbox(message.payload.actor)

      if outboundadapter
        status = codes.OK
        result = outboundadapter
      else
        status = codes.INVALID_ATTR
        result = "Actor not found"

      msg = @buildResult(message.publisher, message.msgid, status, result)
      @send msg

  initChildren: (children)->
    _.forEach children, (childProps) =>
      childProps.trackers = [{
        trackerId : @actor,
        trackerUrl : @inboundAdapters[0].url,
        }]
      @createChild childProps.type, childProps.method, childProps

  pingChannel: (broadcastUrl) ->
    #@log "debug", "Starting a channel broadcasting on #{broadcastUrl}"
    #@trackerChannelAid = @createChild "hchannel", "inproc",
    #  { actor: "channel", outboundAdapters: [ { type: "channel", url: broadcastUrl } ] }
    #interval = setInterval(=>
    #    @send @buildMessage(@trackerChannelAid, "msg", "New event pusblished by tracker #{@actor}")
    #  , 3000)
    #@on "stopping", -> clearInterval(interval)

  findOutbox: (actor) ->
    outboundadapter = undefined
    _.forEach @peers, (peers) =>
      if peers.peerFullId is actor
        unless outboundadapter
          if peers.peerStatus is "started"
            _.forEach peers.peerInbox, (inbox) =>
              if inbox.type is "socket"
                outboundadapter = {type: inbox.type, targetActorAid: actor, url: inbox.url}
    unless outboundadapter
      outTab = []
      _.forEach @peers, (peers) =>
        if peers.peerId is validator.getBareJID(actor)
          outTab.push(peers)
      if outTab.length > 0
        lb_peers = outTab[Math.floor(Math.random() * outTab.length)]
        if lb_peers.peerStatus is "started"
          _.forEach lb_peers.peerInbox, (inbox) =>
            if inbox.type is "socket"
              outboundadapter = {type: inbox.type, targetActorAid: lb_peers.peerId, url: inbox.url}

    outboundadapter

exports.Tracker = Tracker
exports.newActor = (properties) ->
  new Tracker(properties)