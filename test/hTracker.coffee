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
should = require("should")
config = require("./_config")
_ = require "underscore"


describe "hTracker", ->
  hActor = undefined
  hResultStatus = require("../lib/codes").hResultStatus
  Tracker = require "../lib/actors/htracker"

  describe "topology without channel", ->
    before () ->
      topology =
        actor: config.logins[0].urn,
        type: "hTracker"
        children: []
        properties:{}

      hActor = new Tracker topology

    after () ->
      #hActor.h_tearDown()
      hActor = null

    it "should automatically add the trackchannel if not set", (done) ->
      if hActor.topology.children[0].type == "hchannel"
        done()

  describe "other", ->
    before () ->
      topology =
        actor: config.logins[0].urn,
        type: "hTracker"
        children: []
        properties:
          channel:
            actor: "urn:localhost:trackChannel",
            type: "hchannel",
            method: "inproc",
            properties:{}

      hActor = new Tracker topology

      hActor.send = (hMessage) ->

    after () ->
      hActor.h_tearDown()
      hActor = null

    describe "Peer-info", ->
      it "should add peer when receive peer-info", (done) ->
        info = config.makeHMessage(hActor.actor, config.logins[3].urn, "hSignal", {name: "peer-info", params:{peerType:"hactor", peerId:config.logins[2].urn, peerStatus:"started", peerInbox:[]}})
        hActor.h_onMessageInternal info
        hActor.peers.length.should.be.equal(1)
        done()

      it "should remove peer when receive peer-info stopping", (done) ->
        hActor.stopAlert = (actor)->
        info = config.makeHMessage(hActor.actor, config.logins[3].urn, "hSignal", {name: "peer-info", params:{peerType:"hactor", peerId:config.logins[2].urn, peerStatus:"stopped", peerInbox:[]}})
        hActor.h_onMessageInternal info
        hActor.peers.length.should.be.equal(0)
        done()

      it "should remove peer after 3 unreceived peer-info", (done) ->
        hActor.touchDelay = 100
        hActor.timeoutDelay = 300
        hActor.stopAlert = (actor)->
        info = config.makeHMessage(hActor.actor, config.logins[3].urn, "hSignal", {name: "peer-info", params:{peerType:"hactor", peerId:config.logins[2].urn, peerStatus:"started", peerInbox:[]}})
        hActor.h_onMessageInternal info
        hActor.peers.length.should.be.equal(1)
        setTimeout(=>
          hActor.peers.length.should.be.equal(0)
          done()
        , 500)

    describe "Peer-search", ->
      before () ->
        hActor.peers = [
          {peerType:"hactor", peerFullId:config.logins[1].urn, peerId:config.logins[0].urn, peerIP: "127.0.0.1", peerPID: 1212, peerStatus:"ready", peerInbox:[{type:"socket_in", url:"url"}]},
          {peerType:"hactor", peerFullId:config.logins[3].urn, peerId:config.logins[0].urn, peerIP: "127.0.0.1", peerPID: 1212, peerStatus:"started", peerInbox:[]},
          {peerType:"hactor", peerFullId:config.logins[5].urn, peerId:config.logins[0].urn, peerIP: "127.0.0.1", peerPID: 1212, peerStatus:"stopped", peerInbox:[{type:"socket_in", url:"url"}]}
        ]

      it "should send outboundAdapter when the acteur is started and have socket_in adapter", (done) ->
        hActor.send = (hMessage) ->
          hMessage.payload.should.have.property "status", hResultStatus.OK
          hMessage.payload.result.should.be.an.instanceof(Object, null)
          done()

        search = config.makeHMessage(hActor.actor, config.logins[3].urn, "hSignal", {name: "peer-search", params:{actor:config.logins[1].urn, pid: 1212, ip: "127.0.0.1"}})
        search.timeout = 1000
        hActor.h_onMessageInternal search

      it "should send NOT_AVAILABLE when the acteur is not started but not have socket_in adapter", (done) ->
        hActor.send = (hMessage) ->
          hMessage.payload.should.have.property "status", hResultStatus.INVALID_ATTR
          hMessage.payload.result.should.be.equal("Actor not found")
          done()

        search = config.makeHMessage(hActor.actor, config.logins[3].urn, "hSignal", {name: "peer-search", params:{actor:config.logins[3].urn, pid: 1212, ip: "127.0.0.1"}})
        search.timeout = 1000
        hActor.h_onMessageInternal search

      it "should send NOT_AVAILABLE when the acteur is not starting and have socket_in adapter", (done) ->
        hActor.send = (hMessage) ->
          hMessage.payload.should.have.property "status", hResultStatus.INVALID_ATTR
          hMessage.payload.result.should.be.equal("Actor not found")
          done()

        search = config.makeHMessage(hActor.actor, config.logins[3].urn, "hSignal", {name: "peer-search", params:{actor:config.logins[5].urn, pid: 1212, ip: "127.0.0.1"}})
        search.timeout = 1000
        hActor.h_onMessageInternal search

      it "should send outboundAdapter when search actor with bareURN", (done) ->
        hActor.send = (hMessage) ->
          hMessage.payload.should.have.property "status", hResultStatus.OK
          hMessage.payload.result.targetActorAid.should.be.equal(config.logins[1].urn)
          done()

        search = config.makeHMessage(hActor.actor, config.logins[3].urn, "hSignal", {name: "peer-search", params:{actor:config.logins[0].urn, pid: 1212, ip: "127.0.0.1"}})
        search.timeout = 1000
        hActor.h_onMessageInternal search

      it "should send outboundAdapter when search actor with bareURN with load balancing", (done) ->
        @timeout(4000)
        hActor.peers = [
          {peerType:"hactor", peerFullId:config.logins[1].urn, peerId:config.logins[0].urn, peerIP: "127.0.0.1", peerPID: 1212, peerStatus:"ready", peerInbox:[{type:"socket_in", url:"url"}]},
          {peerType:"hactor", peerFullId:config.logins[3].urn, peerId:config.logins[0].urn, peerIP: "127.0.0.1", peerPID: 1212, peerStatus:"ready", peerInbox:[{type:"socket_in", url:"url"}]},
          {peerType:"hactor", peerFullId:config.logins[5].urn, peerId:config.logins[0].urn, peerIP: "127.0.0.1", peerPID: 1212, peerStatus:"ready", peerInbox:[{type:"socket_in", url:"url"}]}
        ]

        goodResult = [config.logins[1].urn, config.logins[3].urn, config.logins[5].urn]
        result1 = 0
        result2 = 0
        result3 = 0
        index = 0
        index2 = 0
        hActor.send = (hMessage) ->
          index2++
          hMessage.payload.should.have.property "status", hResultStatus.OK
          goodResult.should.include(hMessage.payload.result.targetActorAid)
          if hMessage.payload.result.targetActorAid is config.logins[1].urn
            result1++
          else if hMessage.payload.result.targetActorAid is config.logins[3].urn
            result2++
          else
            result3++
          if index2 is 20
            result1.should.be.above(0)
            result2.should.be.above(0)
            result3.should.be.above(0)
            done()

        search = config.makeHMessage(hActor.actor, config.logins[3].urn, "hSignal", {name: "peer-search", params:{actor:config.logins[0].urn, pid: 1212, ip: "127.0.0.1"}})
        search.timeout = 1000
        while index < 20
          hActor.h_onMessageInternal search
          index++

      it "should send outboundAdapter when search actor with bareURN and same PID", (done) ->
        hActor.peers = [
          {peerType:"hactor", peerFullId:config.logins[1].urn, peerId:config.logins[0].urn, peerIP: "127.0.0.1", peerPID: 1212, peerStatus:"ready", peerInbox:[{type:"socket_in", url:"url"}]},
          {peerType:"hactor", peerFullId:config.logins[3].urn, peerId:config.logins[0].urn, peerIP: "127.0.0.1", peerPID: 2121, peerStatus:"ready", peerInbox:[{type:"socket_in", url:"url"}]},
          {peerType:"hactor", peerFullId:config.logins[5].urn, peerId:config.logins[0].urn, peerIP: "192.12.12.12", peerPID: 1212, peerStatus:"ready", peerInbox:[{type:"socket_in", url:"url"}]}
        ]

        hActor.send = (hMessage) ->
          hMessage.payload.should.have.property "status", hResultStatus.OK
          hMessage.payload.result.targetActorAid.should.be.equal(config.logins[1].urn)
          done()

        search = config.makeHMessage(hActor.actor, config.logins[3].urn, "hSignal", {name: "peer-search", params:{actor:config.logins[0].urn, pid: 1212, ip: "127.0.0.1"}})
        search.timeout = 1000
        hActor.h_onMessageInternal search

      it "should send outboundAdapter when search actor with bareURN and same host", (done) ->
        hActor.peers = [
          {peerType:"hactor", peerFullId:config.logins[1].urn, peerId:config.logins[0].urn, peerIP: "127.0.0.1", peerPID: 1212, peerStatus:"ready", peerInbox:[{type:"socket_in", url:"url"}]},
          {peerType:"hactor", peerFullId:config.logins[3].urn, peerId:config.logins[0].urn, peerIP: "127.0.0.1", peerPID: 2121, peerStatus:"ready", peerInbox:[{type:"socket_in", url:"url"}]},
          {peerType:"hactor", peerFullId:config.logins[5].urn, peerId:config.logins[0].urn, peerIP: "192.12.12.12", peerPID: 1212, peerStatus:"ready", peerInbox:[{type:"socket_in", url:"url"}]}
        ]

        hActor.send = (hMessage) ->
          hMessage.payload.should.have.property "status", hResultStatus.OK
          hMessage.payload.result.targetActorAid.should.be.equal(config.logins[5].urn)
          done()

        search = config.makeHMessage(hActor.actor, config.logins[3].urn, "hSignal", {name: "peer-search", params:{actor:config.logins[0].urn, pid: 4242, ip: "192.12.12.12"}})
        search.timeout = 1000
        hActor.h_onMessageInternal search

      it "should send outboundAdapter when search actor with bareURN and other host", (done) ->
        hActor.peers = [
          {peerType:"hactor", peerFullId:config.logins[1].urn, peerId:config.logins[0].urn, peerIP: "127.0.0.1", peerPID: 1212, peerStatus:"ready", peerInbox:[{type:"socket_in", url:"url"}]},
          {peerType:"hactor", peerFullId:config.logins[3].urn, peerId:config.logins[0].urn, peerIP: "127.0.0.1", peerPID: 2121, peerStatus:"ready", peerInbox:[{type:"socket_in", url:"url"}]},
          {peerType:"hactor", peerFullId:config.logins[5].urn, peerId:config.logins[0].urn, peerIP: "192.12.12.12", peerPID: 1212, peerStatus:"ready", peerInbox:[{type:"socket_in", url:"url"}]}
        ]

        answer = [config.logins[1].urn, config.logins[3].urn, config.logins[5].urn]
        hActor.send = (hMessage) ->
          hMessage.payload.should.have.property "status", hResultStatus.OK
          answer.should.include(hMessage.payload.result.targetActorAid)
          done()

        search = config.makeHMessage(hActor.actor, config.logins[3].urn, "hSignal", {name: "peer-search", params:{actor:config.logins[0].urn, pid: 4242, ip: "127.12.12.12"}})
        search.timeout = 1000
        hActor.h_onMessageInternal search