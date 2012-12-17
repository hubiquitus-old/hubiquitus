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
  actorModule = require("../lib/actor/hsession")
  existingCHID = "##{config.getUUID()}@localhost"
  chanWithHeader = "##{config.getUUID()}@localhost"
  inactiveChan = "##{config.getUUID()}@localhost"
  subsChan = "##{config.getUUID()}@localhost"
  DateTab = []
  maxMsgRetrieval = 6

  before () ->
    topology = {
      actor: config.logins[0].jid,
      type: "hsession"
    }
    hActor = actorModule.newActor(topology)

  after () ->
    hActor.h_tearDown()
    hActor = null

  before (done) ->
    @timeout 5000
    createCmd = config.createChannel existingCHID, [config.validJID, config.logins[2].jid], config.validJID, true
    hActor.h_onMessageInternal createCmd,  (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      done()

  before (done) ->
    @timeout 5000
    createCmd = config.createChannel inactiveChan, [config.validJID, config.logins[2].jid], config.validJID, false
    hActor.h_onMessageInternal createCmd,  (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      done()

  before (done) ->
    @timeout 10000
    createCmd = config.createChannel chanWithHeader, [config.validJID, config.logins[2].jid], config.validJID, true
    createCmd.payload.params.headers = {}
    createCmd.payload.params.headers =
      MAX_MSG_RETRIEVAL: "" + maxMsgRetrieval
    hActor.h_onMessageInternal createCmd,  (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.OK

      i = 0
      nbOfPublish = 0
      while i < 11
        publishMsg = config.makeHMessage chanWithHeader, hActor.actor, "string", {}
        publishMsg.timeout = 0
        publishMsg.persistent = true
        hActor.send publishMsg

        nbOfPublish += 1
        if nbOfPublish is 10
          done()
        i++

  before (done) ->
    @timeout 5000
    createCmd = config.createChannel subsChan, [config.logins[2].jid], config.validJID, true
    hActor.h_onMessageInternal createCmd,  (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      done()

  beforeEach ->
    cmd = config.makeHMessage(existingCHID, hActor.actor, "hCommand", {})
    cmd.payload =
      cmd: "hGetLastMessages"
      params:
        nbLastMsg: 5

  it "should return hResult ok if there are no hMessages stored", (done) ->
    hActor.send cmd, (hMessage) ->
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
        hActor.send publishMsg
        count++
      i++

    it "should return hResult error INVALID_ATTR with actor not a channel", (done) ->
      cmd.actor = hActor.actor
      hActor.h_onMessageInternal cmd, (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.NOT_AVAILABLE
        hMessage.payload.should.have.property('result').and.match(/Command/)
        done()


    it "should return hResult error MISSING_ATTR if no channel is passed", (done) ->
      delete cmd.actor
      hActor.send cmd, (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.MISSING_ATTR
        hMessage.payload.should.have.property('result').and.be.a('string');
        done()


    it "should return hResult error NOT_AUTHORIZED if publisher not in subscribers list", (done) ->
      cmd.actor = subsChan
      hActor.send cmd, (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.NOT_AUTHORIZED
        hMessage.payload.should.have.property('result').and.be.a('string')
        done()


    it "should return hResult error NOT_AVAILABLE if channel does not exist", (done) ->
      cmd.actor = "#this channel does not exist@localhost"
      hActor.send cmd, (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.NOT_AVAILABLE
        hMessage.payload.should.have.property('result').and.be.a('string')
        done()


    it "should return hResult error NOT_AUTHORIZED if channel inactive", (done) ->
      cmd.actor = inactiveChan
      hActor.send cmd, (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.NOT_AUTHORIZED
        hMessage.payload.should.have.property('result').and.be.a('string')
        done()


    it "should return hResult ok with 10 msgs if not header in chan and cmd quant not a number", (done) ->
      cmd.payload.params.nbLastMsg = "not a number"
      cmd.actor = existingCHID
      hActor.send cmd, (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.OK
        hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
        hMessage.payload.result.length.should.be.equal(10)
        done()


    it "should return hResult ok with 10 messages if not default in channel or cmd", (done) ->
      delete cmd.payload.params.nbLastMsg

      cmd.actor = existingCHID
      hActor.send cmd, (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.OK
        hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
        hMessage.payload.result.length.should.be.equal(10)
        done()


    it "should return hResult ok with 10 last messages", (done) ->
      delete cmd.payload.params.nbLastMsg

      cmd.actor = existingCHID
      hActor.send cmd, (hMessage) ->
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


    it "should return hResult ok with default messages of channel if not specified", (done) ->
      delete cmd.payload.params.nbLastMsg

      cmd.actor = chanWithHeader
      hActor.send cmd, (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.OK
        hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
        hMessage.payload.result.length.should.be.equal(maxMsgRetrieval)
        done()


    it "should return hResult ok with nb of msgs in cmd if specified with headers", (done) ->
      length = 4
      cmd.payload.params.nbLastMsg = length
      hActor.send cmd, (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.OK
        hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
        hMessage.payload.result.length.should.be.equal(length)
        done()


    it "should return hResult ok with nb of msgs in cmd if specified if header specified", (done) ->
      length = 4
      cmd.payload.params.nbLastMsg = length
      cmd.actor = chanWithHeader
      hActor.send cmd, (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.OK
        hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
        hMessage.payload.result.length.should.be.equal(length)
        done()

    describe "#FilterMessage()", ->
      setMsg = undefined

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
          publishMsg.author = "u2@localhost"
          hActor.send publishMsg

          count++
          i++

      beforeEach ->
        setMsg = config.makeHMessage(hActor.actor, config.logins[0].jid, "hCommand", {})
        setMsg.payload =
          cmd: "hSetFilter"
          params: {}

      it "should return Ok with default messages of channel if not specified and message respect filter", (done) ->
        delete cmd.payload.params.nbLastMsg

        setMsg.payload.params = in:
          publisher: ["u1@localhost"]

        hActor.h_onMessageInternal setMsg, ->

        hActor.send cmd, (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", status.OK
          hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
          hMessage.payload.result.length.should.be.equal(10);

          done()


      it "should return Ok with only filtered messages with right quantity", (done) ->
        cmd.payload.params.nbLastMsg = 3
        setMsg.payload.params = in:
          author: ["u2@localhost"]

        hActor.h_onMessageInternal setMsg, ->
        hActor.send cmd, (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", status.OK
          hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
          hMessage.payload.result.length.should.be.equal(3);

          i = 0
          while i < hMessage.payload.result.length
            hMessage.payload.result[i].should.have.property "author", "u2@localhost"
            i++
          done()


      it "should return Ok with only filtered messages with less quantity if demanded does not exist.", (done) ->
        cmd.payload.params.nbLastMsg = 1000
        setMsg.payload.params = in:
          author: ["u2@localhost"]

        hActor.h_onMessageInternal setMsg, ->

        hActor.send cmd, (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", status.OK
          hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
          hMessage.payload.result.length.should.be.equal(5);

          i = 0
          while i < hMessage.payload.result.length
            hMessage.payload.result[i].should.have.property "author", "u2@localhost"
            i++
          done()




