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
  status = require("../lib/codes").hResultStatus
  actorModule = require("../lib/actor/hchannel")
  existingCHID = "urn:localhost:##{config.getUUID()}"
  DateTab = []
  maxMsgRetrieval = 6

  before () ->
    topology = {
      actor: existingCHID,
      type: "hchannel",
      properties: {
        subscribers:[existingCHID, config.logins[2].urn],
        listenOn: "tcp://127.0.0.1:1221",
        broadcastOn: "tcp://127.0.0.1:2998"
      }
    }
    hActor = actorModule.newActor(topology)

  after () ->
    hActor.h_tearDown()
    hActor = null

  beforeEach ->
    cmd = config.makeHMessage(existingCHID, hActor.actor, "hCommand", {})
    cmd.payload =
      cmd: "hGetLastMessages"
      params:
        nbLastMsg: 5
        filter: {}

  it "should return hResult ok if there are no hMessages stored", (done) ->
    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      hMessage.payload.should.have.property('result').and.be.an.instanceof(Array);
      hMessage.payload.result.length.should.equal(0)
      done()

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
      hActor.createChild "hactor", "inproc", {actor: config.logins[0].urn}, (child) =>
        cmd.actor = child.actor
        child.h_onMessageInternal cmd, (hMessage) ->
          hMessage.should.have.property "ref", cmd.msgid
          hMessage.payload.should.have.property "status", status.NOT_AVAILABLE
          done()


    it "should return hResult error MISSING_ATTR if no channel is passed", (done) ->
      delete cmd.actor
      hActor.h_onMessageInternal cmd, (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.MISSING_ATTR
        hMessage.payload.should.have.property('result').and.be.a('string');
        done()


    it "should return hResult error NOT_AUTHORIZED if publisher not in subscribers list", (done) ->
      hActor.properties.subscribers = [config.logins[2].urn]
      hActor.h_onMessageInternal cmd, (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.NOT_AUTHORIZED
        hMessage.payload.should.have.property('result').and.be.a('string')
        hActor.properties.subscribers = [existingCHID, config.logins[2].urn]
        done()

    it "should return hResult ok with 10 msgs if cmd quant not a number", (done) ->
      cmd.payload.params.nbLastMsg = "not a number"
      hActor.h_onMessageInternal cmd, (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.OK
        hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
        hMessage.payload.result.length.should.be.equal(10)
        done()


    it "should return hResult ok with 10 messages if not specified in cmd", (done) ->
      delete cmd.payload.params.nbLastMsg
      hActor.h_onMessageInternal cmd, (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.OK
        hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
        hMessage.payload.result.length.should.be.equal(10)
        done()


    it "should return hResult ok with 10 last messages", (done) ->
      delete cmd.payload.params.nbLastMsg
      hActor.h_onMessageInternal cmd, (hMessage) ->
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

    it "should return hResult ok with nb of msgs in cmd", (done) ->
      length = 4
      cmd.payload.params.nbLastMsg = length
      hActor.h_onMessageInternal cmd, (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.OK
        hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
        hMessage.payload.result.length.should.be.equal(length)
        done()

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
        cmd.payload.params.filter = in:
          publisher: [hActor.actor]

        hActor.h_onMessageInternal cmd, (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", status.OK
          hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
          hMessage.payload.result.length.should.be.equal(10);

          done()


      it "should return Ok with only filtered messages with right quantity", (done) ->
        cmd.payload.params.nbLastMsg = 3
        cmd.payload.params.filter = in:
          author: ["urn:localhost:u2"]

        hActor.h_onMessageInternal cmd, (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", status.OK
          hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
          hMessage.payload.result.length.should.be.equal(3);

          i = 0
          while i < hMessage.payload.result.length
            hMessage.payload.result[i].should.have.property "author", "urn:localhost:u2"
            i++
          done()


      it "should return Ok with only filtered messages with less quantity if demanded does not exist.", (done) ->
        cmd.payload.params.nbLastMsg = 1000
        cmd.payload.params.filter = in:
          author: ["urn:localhost:u2"]

        hActor.h_onMessageInternal cmd, (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", status.OK
          hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
          hMessage.payload.result.length.should.be.equal(5);

          i = 0
          while i < hMessage.payload.result.length
            hMessage.payload.result[i].should.have.property "author", "urn:localhost:u2"
            i++
          done()




