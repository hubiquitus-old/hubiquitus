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

describe "hGetThread", ->
  cmd = undefined
  hActor = undefined
  status = require("../lib/codes").hResultStatus
  actorModule = require("../lib/actor/hsession")
  activeChannel = "##{config.getUUID()}@localhost"
  inactiveChannel = "##{config.getUUID()}@localhost"
  notInPart = "##{config.getUUID()}@localhost"
  convid = undefined
  publishedMessages = 0

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
    createCmd = config.createChannel activeChannel, [config.validJID], config.validJID, true
    hActor.h_onMessageInternal createCmd,  (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      done()

  before (done) ->
    @timeout 5000
    createCmd = config.createChannel inactiveChannel, [config.validJID], config.validJID, false
    hActor.h_onMessageInternal createCmd,  (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      done()

  before (done) ->
    @timeout 5000
    createCmd = config.createChannel notInPart, [config.logins[2].jid], config.validJID, false
    hActor.h_onMessageInternal createCmd,  (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      done()

  #Publish first message to get a valid convid and following ones with same convid
  before ->
    publishMsg = config.makeHMessage activeChannel, hActor.actor, "string", {}
    publishMsg.timeout = 0
    publishMsg.persistent = true
    publishMsg.published = new Date().getTime()
    convid = publishMsg.msgid
    hActor.send publishMsg
    publishedMessages++

    i = 0
    while i < 4
      publishMsg = config.makeHMessage activeChannel, hActor.actor, "string", {}
      publishMsg.timeout = 0
      publishMsg.persistent = true
      publishMsg.published = new Date().getTime()
      publishMsg.convid = convid
      hActor.send publishMsg
      publishedMessages++
      i++

  beforeEach ->
    cmd = config.makeHMessage(activeChannel, hActor.actor, "hCommand", {})
    cmd.payload =
      cmd: "hGetThread"
      params:
        convid: convid

  it "should return hResult error INVALID_ATTR without params", (done) ->
    delete cmd.payload.params
    hActor.send cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a "string"
      done()


  it "should return hResult error INVALID_ATTR with params not an object", (done) ->
    cmd.payload.params = "string"
    hActor.send cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a "string"
      done()


  it "should return hResult error NOT_AUTHORIZED if the sender is not a subscriber", (done) ->
    cmd.actor = notInPart
    hActor.send cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.NOT_AUTHORIZED
      hMessage.payload.should.have.property("result").and.be.a "string"
      done()


  it "should return hResult error NOT_AUTHORIZED if the channel is inactive", (done) ->
    cmd.actor = inactiveChannel
    hActor.send cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.NOT_AUTHORIZED
      hMessage.payload.should.have.property("result").and.match /inactive/
      done()


  it "should return hResult error MISSING_ATTR if actor is not provided", (done) ->
    delete cmd.actor

    hActor.send cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.MISSING_ATTR
      hMessage.payload.should.have.property("result").and.match /actor/
      done()


  it "should return hResult error INVALID_ATTR with actor not a channel", (done) ->
    cmd.actor = hActor.actor
    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.NOT_AVAILABLE
      hMessage.payload.should.have.property("result").and.match /Command/
      done()


  it "should return hResult error MISSING_ATTR if convid is not provided", (done) ->
    delete cmd.payload.params.convid

    hActor.send cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.MISSING_ATTR
      hMessage.payload.should.have.property("result").and.match /convid/
      done()


  it "should return hResult error INVALID_ATTR with convid not a string", (done) ->
    cmd.payload.params.convid = []
    hActor.send cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.match /convid/
      done()


  it "should return hResult error NOT_AVAILABLE if the channel does not exist", (done) ->
    cmd.actor = "#this channel does not exist@localhost"
    hActor.send cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.NOT_AVAILABLE
      hMessage.payload.should.have.property("result").and.be.a "string"
      done()


  it "should return hResult OK with an empty [] if no messages found matching convid", (done) ->
    cmd.payload.params.convid = config.getUUID()
    hActor.send cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      hMessage.payload.result.should.be.an.instanceof(Array)
      hMessage.payload.result.length.should.be.equal(0);
      done()


  it "should return hResult OK with an [] containing all messages with same convid sort older to newer", (done) ->
    hActor.send cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      hMessage.payload.result.should.be.an.instanceof(Array)
      hMessage.payload.result.length.should.be.equal(publishedMessages)
      msg1 = new Date(hMessage.payload.result[0].published).getTime()
      msgX = new Date(hMessage.payload.result[publishedMessages - 1].published).getTime()
      diff = msg1 - msgX
      diff.should.be.below 0
      done()


  it "should return hResult OK with an [] containing all messages with same convid sort newer to older when invalid params sort", (done) ->
    cmd.payload.params.sort = "hello"
    hActor.send cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      hMessage.payload.result.should.be.an.instanceof(Array)
      hMessage.payload.result.length.should.be.equal(publishedMessages)
      msg1 = new Date(hMessage.payload.result[0].published).getTime()
      msgX = new Date(hMessage.payload.result[publishedMessages - 1].published).getTime()
      diff = msg1 - msgX
      diff.should.be.below 0
      done()


  it "should return hResult OK with an [] containing all messages with same convid sort newer to older", (done) ->
    cmd.payload.params.sort = -1
    hActor.send cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      hMessage.payload.result.should.be.an.instanceof(Array)
      hMessage.payload.result.length.should.be.equal(publishedMessages)
      msg1 = new Date(hMessage.payload.result[0].published).getTime()
      msgX = new Date(hMessage.payload.result[publishedMessages - 1].published).getTime()
      diff = msg1 - msgX
      diff.should.be.above 0
      done()


  describe "#FilterMessage()", ->
    filterMessagesPublished = 0
    convid2 = config.getUUID()

    before () ->
      publishMsg = config.makeHMessage activeChannel, hActor.actor, "a type", {}
      publishMsg.timeout = 0
      publishMsg.persistent = true
      publishMsg.published = new Date().getTime()
      publishMsg.convid = convid
      hActor.send publishMsg
      publishedMessages++

      i = 0
      while i < 3
        publishMsg = config.makeHMessage activeChannel, hActor.actor, "a type", {}
        publishMsg.timeout = 0
        publishMsg.persistent = true
        publishMsg.published = new Date().getTime()
        publishMsg.convid = convid2
        hActor.send publishMsg
        filterMessagesPublished++
        i++

      i = 0
      while i < 3
        publishMsg = config.makeHMessage activeChannel, hActor.actor, "another type", {}
        publishMsg.timeout = 0
        publishMsg.persistent = true
        publishMsg.published = new Date().getTime()
        publishMsg.convid = convid2
        hActor.send publishMsg
        filterMessagesPublished++
        i++

    before (done) ->
      filterCmd = config.makeHMessage(hActor.actor, config.logins[0].jid, "hCommand", {})
      filterCmd.payload =
        cmd: "hSetFilter"
        params:
          eq:
            type: "a type"

      hActor.h_onMessageInternal filterCmd, (hMessage) ->
        hMessage.payload.should.have.property "status", status.OK
        done()


    it "should not return msgs if a msg OTHER than the first one pass the filter", (done) ->
      hActor.send cmd, (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.OK
        hMessage.payload.result.should.be.an.instanceof(Array)
        hMessage.payload.result.length.should.be.equal(0)
        done()


    it "should return ALL convid msgs if the first one complies with the filter", (done) ->
      cmd.payload.params.convid = convid2
      hActor.send cmd, (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.OK
        hMessage.payload.result.should.be.an.instanceof(Array)
        hMessage.payload.result.length.should.be.equal(filterMessagesPublished);
        done()



