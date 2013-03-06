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
factory = require "../hfactory"
_ = require "underscore"
codes = require("../codes").hResultStatus
validator = require "../validator"

class Tracker extends Actor

  constructor: (topology) ->
    #TODO check properties
    @peers = []
    @trackerChannelAid = topology.properties.channel.actor
    topology.children.unshift topology.properties.channel
    @timerPeers = {}
    @timeoutDelay = 180000
    super

  h_onSignal: (hMessage) ->
    @log "debug", "Tracker received a hSignal: #{JSON.stringify(hMessage)}"
    if hMessage.payload.name is "peer-info"
      existPeer = false
      index = 0
      _.forEach @peers, (peers) =>
        if peers.peerFullId is hMessage.publisher
          existPeer = true
          clearTimeout(@timerPeers[hMessage.publisher])
          peers.peerStatus = hMessage.payload.params.peerStatus
          peers.peerInbox = hMessage.payload.params.peerInbox
          if peers.peerStatus is "stopped"
            @stopAlert(hMessage.publisher)
            @peers.splice(index, 1)
            @removePeer(hMessage.publisher)
          else
            @timerPeers[hMessage.publisher] = setTimeout(=>
              delete @timerPeers[hMessage.publisher]
              @stopAlert(hMessage.publisher)
              index2 = 0
              _.forEach @peers, (peers) =>
                if peers.peerFullId is hMessage.publisher
                  @peers.splice(index2, 1)
                index2++
              @removePeer(hMessage.publisher)
            , @timeoutDelay)
        index++
      if existPeer isnt true
        @peers.push {peerType:hMessage.payload.params.peerType, peerFullId:hMessage.publisher, peerId:hMessage.payload.params.peerId, peerStatus:hMessage.payload.params.peerStatus, peerInbox:hMessage.payload.params.peerInbox}
        @timerPeers[hMessage.publisher] = setTimeout(=>
          delete @timerPeers[hMessage.publisher]
          @stopAlert(hMessage.publisher)
          index = 0
          _.forEach @peers, (peers) =>
            if peers.peerFullId is hMessage.publisher
              @peers.splice(index, 1)
            index++
          @removePeer(hMessage.publisher)
        , @timeoutDelay)
        outbox = @findOutbox(hMessage.publisher, true)
        if outbox
          @outboundAdapters.push factory.newAdapter(outbox.type, { targetActorAid: outbox.targetActorAid, owner: @, url: outbox.url })

    else if hMessage.payload.name is "peer-search"
      # TODO reflexion sur le lookup et implementation
      outboundadapter = @findOutbox(hMessage.payload.params.actor, false)

      if outboundadapter
        status = codes.OK
        result = outboundadapter
      else
        status = codes.INVALID_ATTR
        result = "Actor not found"

      @send @buildResult(hMessage.publisher, hMessage.msgid, status, result)

  initChildren: (children)->
    _.forEach children, (childProps) =>
      childProps.trackers = [{
        trackerId : @actor,
        trackerUrl : @inboundAdapters[0].url,
        trackerChannel : @trackerChannelAid
        }]
      @createChild childProps.type, childProps.method, childProps


  findOutbox: (actor, tracker) ->
    outboundadapter = undefined
    _.forEach @peers, (peers) =>
      if peers.peerFullId is actor
        unless outboundadapter
          if (peers.peerStatus isnt "starting" and peers.peerStatus isnt "stopped") or tracker is true
            _.forEach peers.peerInbox, (inbox) =>
              if inbox.type is "socket_in"
                outboundadapter = {type: "socket_out", targetActorAid: actor, url: inbox.url}
    unless outboundadapter
      outTab = []
      _.forEach @peers, (peers) =>
        if peers.peerId is validator.getBareURN(actor) and peers.peerStatus is "ready" and peers.peerInbox.length > 0
          outTab.push(peers)
      if outTab.length > 0
        lb_peers = outTab[Math.floor(Math.random() * outTab.length)]
        _.forEach lb_peers.peerInbox, (inbox) =>
           if inbox.type is "socket_in"
             outboundadapter = {type: "socket_out", targetActorAid: lb_peers.peerFullId, url: inbox.url}
    outboundadapter

  stopAlert: (actor) ->
    @send @buildSignal(@trackerChannelAid, "hStopAlert", actor, {headers:{h_quickFilter: actor}})

exports.Tracker = Tracker
exports.newActor = (topology) ->
  new Tracker(topology)