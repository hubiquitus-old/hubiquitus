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

Actor = require "./hactor"
factory = require "../hfactory"
_ = require "underscore"
codes = require("../codes").hResultStatus
validator = require "../validator"

#
# Class that defines a tracker actor
#
class Tracker extends Actor

# @property {Array<Object>} List all the peers connect in the hEngine
  peers: undefined
  # @property {string} URN of the tracker's channel
  trackerChannelAid: undefined
  # @property {string} URN of the tracker's pub channel
  pubChannelAid: undefined
  # @property {object} List all timeout before remove a peer if he doesn't send a peer-info
  timerPeers: undefined
  # @property {integer} Delay before removing peer if he doesn't send a peer-info
  timeoutDelay: undefined


  #
  # Actor's constructor
  # @param topology {object} Launch topology of the actor
  #
  constructor: (topology) ->
    #TODO check properties
    @peers = []
    @trackerChannelAid = topology.properties.channel.actor
    unless topology.children
      topology.children = []

    if topology.properties.pubChannel
      @pubChannelAid = topology.properties.pubChannel.actor
      topology.children.unshift topology.properties.pubChannel

    topology.children.unshift topology.properties.channel
    @timerPeers = {}
    @timeoutDelay = 180000
    super
    @type = "tracker"

  #
  # @overload h_onSignal(hMessage)
  #   Private method that processes hSignal message.
  #   The hSignal are service's message
  #   @private
  #   @param hMessage {object} the hSignal receive
  #
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

      if @pubChannelAid
        @send @buildMessage @pubChannelAid, "peer-info", hMessage.payload.params

    else if hMessage.payload.name is "peer-search"
      # TODO reflexion sur le lookup et implementation
      params = hMessage.payload.params
      outboundadapter = @findOutbox(params.actor, false, params.ip, params.pid)

      if outboundadapter
        status = codes.OK
        result = outboundadapter
      else
        status = codes.INVALID_ATTR
        result = "Actor not found"

      @send @buildResult(hMessage.publisher, hMessage.msgid, status, result)

  #
  # @overload initChildren(children)
  #   Method called by constructor to initializing actor's children
  #   The tracker add his properties for all his children
  #   @param children {Array<Object>} Actor's children and their topology
  #
  initChildren: (children)->
    _.forEach children, (childProps) =>
      childProps.trackers = [{
        trackerId : @actor,
        trackerUrl : @inboundAdapters[0].url,
        trackerChannel : @trackerChannelAid
      }]
      unless childProps.method
        childProps.method = "inproc"
      @createChild childProps.type, childProps.method, childProps

  #
  # Method called to search an adress for a specific peer)
  # @param actor {string} URN of the search peer
  # @param tracker {boolean} True if it's the tracker which search the peer. In this case the state of the peer is ignored.
  #
  findOutbox: (actor, tracker, ip, pid) ->
    # Search with FullURN
    outboundadapter = undefined
    _.forEach @peers, (peers) =>
      if peers.peerFullId is actor
        unless outboundadapter
          if (peers.peerStatus isnt "starting" and peers.peerStatus isnt "stopped") or tracker is true
            _.forEach peers.peerInbox, (inbox) =>
              if inbox.type is "socket_in"
                outboundadapter = {type: "socket_out", targetActorAid: actor, url: inbox.url}
    # If not find FullURN, search BareURN
    unless outboundadapter
      samePID = []
      sameHost = []
      outTab = []
      _.forEach @peers, (peers) =>
        if peers.peerId is validator.getBareURN(actor) and peers.peerPID is pid and peers.peerIP is ip and peers.peerStatus is "ready" and peers.peerInbox.length > 0
          samePID.push(peers)
        else if peers.peerId is validator.getBareURN(actor) and peers.peerIP is ip and peers.peerStatus is "ready" and peers.peerInbox.length > 0
          sameHost.push(peers)
        else if peers.peerId is validator.getBareURN(actor) and peers.peerStatus is "ready" and peers.peerInbox.length > 0
          outTab.push(peers)
      if samePID.length > 0
        outTab = samePID
      else if sameHost.length > 0
        outTab = sameHost
      if outTab.length > 0
        lb_peers = outTab[Math.floor(Math.random() * outTab.length)]
        _.forEach lb_peers.peerInbox, (inbox) =>
          if inbox.type is "socket_in"
            outboundadapter = {type: "socket_out", targetActorAid: lb_peers.peerFullId, url: inbox.url}
    outboundadapter

  #
  # Method called when an actor stop to warn the other peer
  # @param actor {string} actor who stop
  #
  stopAlert: (actor) ->
    @send @h_buildSignal(@trackerChannelAid, "hStopAlert", actor, {headers:{h_quickFilter: actor}})
    if @pubChannelAid
      @send @buildMessage @pubChannelAid, "peer-stop", actor


module.exports = Tracker
