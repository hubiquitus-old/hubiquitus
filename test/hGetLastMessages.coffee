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
describe "hGetLastMessages", ->
  cmd = undefined
  hActor = undefined
  hActor2 = undefined
  status = require("../lib/codes").hResultStatus
  actorModule = require("../lib/actor/hchannel")
  actorModule2 = require("../lib/actor/hactor")
  existingCHID = "urn:localhost:#{config.getUUID()}"
  DateTab = []

  before () ->
    topology = {
      actor: existingCHID,
      type: "hchannel",
      properties: {
        subscribers:[existingCHID, config.logins[2].urn],
        listenOn: "tcp://127.0.0.1:1221",
        broadcastOn: "tcp://127.0.0.1:2998",
        db:{
          dbName: "test",
          dbCollection: existingCHID
        }
      }
    }
    hActor = actorModule.newActor(topology)

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
    cmd = config.makeHMessage(existingCHID, hActor.actor, "hCommand", {})
    cmd.payload =
      cmd: "hGetLastMessages"
      params:
        nbLastMsg: 5
      filter: {}

  it "should return hResult ok if there are no hMessages stored", (done) ->
    hActor.send = (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      hMessage.payload.should.have.property('result').and.be.an.instanceof(Array);
      hMessage.payload.result.length.should.equal(0)
      hActor.send = (hMessage) ->
      done()

    hActor.h_onMessageInternal cmd

  describe "Test with messages published", ->
    i = 0
    while i < 10
      count = 0
      date = new Date(100000 + i * 100000).getTime()
      DateTab.push date
      before ->
        publishMsg = config.makeHMessage existingCHID, hActor.actor, "string", {}
        publishMsg.timeout = 0
        publishMsg.persistent = true
        publishMsg.published = DateTab[count]
        hActor.h_onMessageInternal publishMsg
        count++
      i++

    it "should return hResult error NOT_AVAILABLE with actor not a channel", (done) ->
      cmd.actor = hActor2.actor
      hActor2.send = (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.NOT_AVAILABLE
        done()

      hActor2.h_onMessageInternal cmd


    it "should return hResult error MISSING_ATTR if no channel is passed", (done) ->
      delete cmd.actor
      hActor.send = (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.MISSING_ATTR
        hMessage.payload.should.have.property('result').and.be.a('string');
        done()

      hActor.h_onMessageInternal cmd


    it "should return hResult error NOT_AUTHORIZED if publisher not in subscribers list", (done) ->
      hActor.properties.subscribers = [config.logins[2].urn]
      hActor.send = (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.NOT_AUTHORIZED
        hMessage.payload.should.have.property('result').and.be.a('string')
        hActor.properties.subscribers = [existingCHID, config.logins[2].urn]
        done()

      hActor.h_onMessageInternal cmd

    it "should return hResult ok with 10 msgs if cmd quant not a number", (done) ->
      cmd.payload.params.nbLastMsg = "not a number"
      hActor.send = (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.OK
        hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
        hMessage.payload.result.length.should.be.equal(10)
        done()

      hActor.h_onMessageInternal cmd


    it "should return hResult ok with 10 messages if not specified in cmd", (done) ->
      delete cmd.payload.params.nbLastMsg
      hActor.send = (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.OK
        hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
        hMessage.payload.result.length.should.be.equal(10)
        done()

      hActor.h_onMessageInternal cmd


    it "should return hResult ok with 10 last messages", (done) ->
      delete cmd.payload.params.nbLastMsg
      hActor.send = (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.OK
        hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
        hMessage.payload.result.length.should.be.equal(10)

        i = 0
        while i < 10
          int = DateTab.length - (i + 1)

          #Should be a string for compare
          supposedDate = "" + DateTab[int]
          trueDate = "" + hMessage.payload.result[i].published
          supposedDate.should.be.eql trueDate
          i++
        done()

      hActor.h_onMessageInternal cmd

    it "should return hResult ok with nb of msgs in cmd", (done) ->
      length = 4
      cmd.payload.params.nbLastMsg = length
      hActor.send = (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.OK
        hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
        hMessage.payload.result.length.should.be.equal(length)
        hActor.send = (hMessage) ->
        done()

      hActor.h_onMessageInternal cmd

    describe "#FilterMessage()", ->

      before ->
        i = 0
        while i < 5
          count = 0
          date = new Date(100000 + i * 100000).getTime()
          DateTab.push date
          publishMsg = config.makeHMessage existingCHID, hActor.actor, "string", {}
          publishMsg.timeout = 0
          publishMsg.persistent = true
          publishMsg.published = DateTab[count]
          publishMsg.author = "urn:localhost:u2"
          hActor.h_onMessageInternal publishMsg

          count++
          i++


      it "should return Ok with default messages of channel if not specified and message respect filter", (done) ->
        delete cmd.payload.params.nbLastMsg
        cmd.payload.filter = in:
          publisher: [hActor.actor]

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", status.OK
          hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
          hMessage.payload.result.length.should.be.equal(10);
          done()

        hActor.h_onMessageInternal cmd


      it "should return Ok with only filtered messages with right quantity", (done) ->
        cmd.payload.params.nbLastMsg = 3
        cmd.payload.filter = in:
          author: ["urn:localhost:u2"]

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", status.OK
          hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
          hMessage.payload.result.length.should.be.equal(3);

          i = 0
          while i < hMessage.payload.result.length
            hMessage.payload.result[i].should.have.property "author", "urn:localhost:u2"
            i++
          done()

        hActor.h_onMessageInternal cmd


      it "should return Ok with only filtered messages with less quantity if demanded does not exist.", (done) ->
        cmd.payload.params.nbLastMsg = 1000
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
