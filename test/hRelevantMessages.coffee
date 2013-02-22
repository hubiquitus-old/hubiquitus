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

describe "hRelevantMessages", ->
  status = require("../lib/codes").hResultStatus
  actorModule = require("../lib/actor/hchannel")
  actorModule2 = require("../lib/actor/hactor")
  cmd = undefined
  hActor = undefined
  hActor2 = undefined
  nbMsgs = 10
  activeChan = "urn:localhost:#{config.getUUID()}"

  before (done) ->
    topology = {
      actor: activeChan,
      type: "hchannel",
      properties: {
        subscribers:[activeChan],
        listenOn: "tcp://127.0.0.1:1221",
        broadcastOn: "tcp://127.0.0.1:2998",
        db:{
          host: "localhost",
          port: 27017,
          name: "test"
        },
        collection: activeChan
      }
    }
    hActor = actorModule.newActor(topology)
    hActor.setStatus "starting"
    hActor.initialize = (ready) =>
      hActor.h_connectToDatabase hActor.properties.db, () =>
        ready()
        done()
    hActor.h_start()

  before () ->
    topology = {
        actor: config.logins[0].urn,
        type: "hactor",
        properties: {}
    }
    hActor2 = actorModule2.newActor(topology)

  after () ->
    hActor.h_tearDown()
    hActor = null
    hActor2.h_tearDown()
    hActor2 = null

  beforeEach ->
    cmd = config.makeHMessage(activeChan, hActor.actor, "hCommand", {})
    cmd.payload =
      cmd: "hRelevantMessages"
      params: {}
      filter: {}

  it "should return hResult OK with an empty array if no matching msgs found", (done) ->
    hActor.send = (hMessage) ->
      hMessage.payload.should.have.property "status", status.OK
      hMessage.payload.result.length.should.be.eql 0
      done()

    hActor.h_onMessageInternal cmd

  describe "Test with messages published", ->

    before (done) ->
      hActor.send = (hMessage) =>
      i = 0
      nbOfPublish = 0
      while i < nbMsgs
        publishMsg = config.makeHMessage activeChan, hActor.actor, "string", {}
        publishMsg.timeout = 0
        publishMsg.persistent = true
        publishMsg.relevance = new Date(new Date().getTime() + 100000).getTime()
        hActor.h_onMessageInternal publishMsg
        nbOfPublish++
        i++

      i = 0
      while i < nbMsgs
        publishMsg = config.makeHMessage activeChan, hActor.actor, "string", {}
        publishMsg.timeout = 0
        publishMsg.persistent = true
        publishMsg.relevance = new Date(new Date().getTime() - 100000).getTime()
        hActor.h_onMessageInternal publishMsg
        nbOfPublish++
        i++

      i = 0
      while i < nbMsgs
        publishMsg = config.makeHMessage activeChan, hActor.actor, "string", {}
        publishMsg.timeout = 0
        publishMsg.persistent = true
        hActor.h_onMessageInternal publishMsg
        nbOfPublish++
        i++

      if nbOfPublish is 30
        done()

    it "should return hResult error MISSING_ATTR if actor is missing", (done) ->
      delete cmd.actor
      hActor.send = (hMessage) ->
        hMessage.payload.should.have.property "status", status.MISSING_ATTR
        hMessage.payload.result.should.match /actor/
        done()

      hActor.h_onMessageInternal cmd


    it "should return hResult error NOT_AVAILABLE with actor not a channel", (done) ->
      cmd.actor = hActor2.actor
      hActor2.send = (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.NOT_AVAILABLE
        done()

      hActor2.h_onMessageInternal cmd


    it "should return hResult error NOT_AUTHORIZED if not in subscribers list", (done) ->
      hActor.properties.subscribers = [config.logins[2].urn]
      hActor.send = (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.NOT_AUTHORIZED
        hMessage.payload.should.have.property('result').and.be.a('string')
        hActor.properties.subscribers = [activeChan]
        done()

      hActor.h_onMessageInternal cmd


    it "should return hResult OK with an array of valid messages and without msgs missing relevance", (done) ->
      hActor.send = (hMessage) ->
        hMessage.payload.should.have.property "status", status.OK
        hMessage.payload.result.length.should.be.eql nbMsgs

        i = 0
        while i < hMessage.payload.result.length
          hMessage.payload.result[i].relevance.should.be.above new Date().getTime()
          i++
        done()

      hActor.h_onMessageInternal cmd

    describe "#FilterMessage()", ->

      before ->
        hActor.send = (hMessage) =>
        i = 0
        while i < 5
          publishMsg = config.makeHMessage activeChan, hActor.actor, "string", {}
          publishMsg.timeout = 0
          publishMsg.persistent = true
          publishMsg.relevance = new Date(new Date().getTime() + 100000).getTime()
          publishMsg.author = "urn:localhost:u2"
          hActor.h_onMessageInternal publishMsg
          i++

      it "should return Ok with messages respect filter", (done) ->
        cmd.payload.filter = in:
          publisher: [activeChan]

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", status.OK
          hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
          hMessage.payload.result.length.should.be.equal(15);
          done()

        hActor.h_onMessageInternal cmd


      it "should return Ok with only filtered messages with right quantity", (done) ->
        cmd.payload.filter = in:
          author: ["urn:localhost:u2"]

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", status.OK
          hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
          hMessage.payload.result.length.should.be.equal(5);

          i = 0
          while i < hMessage.payload.result.length
            hMessage.payload.result[i].should.have.property "author", "urn:localhost:u2"
            i++
          done()

        hActor.h_onMessageInternal cmd