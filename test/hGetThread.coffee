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
  actorModule = require("../lib/actor/hchannel")
  existingCHID = "urn:localhost:##{config.getUUID()}"
  convid = undefined
  publishedMessages = 0

  before () ->
    topology = {
      actor: existingCHID,
      type: "hchannel",
      properties: {
        subscribers:[existingCHID],
        broadcastOn: "tcp://127.0.0.1:2998"
      }
    }
    hActor = actorModule.newActor(topology)

  after () ->
    hActor.h_tearDown()
    hActor = null

  #Publish first message to get a valid convid and following ones with same convid
  before ->
    publishMsg = config.makeHMessage existingCHID, hActor.actor, "string", {}
    publishMsg.timeout = 0
    publishMsg.persistent = true
    publishMsg.published = new Date().getTime()
    convid = publishMsg.msgid
    hActor.h_onMessageInternal publishMsg
    publishedMessages++

    i = 0
    while i < 4
      publishMsg = config.makeHMessage existingCHID, hActor.actor, "string", {}
      publishMsg.timeout = 0
      publishMsg.persistent = true
      publishMsg.published = new Date().getTime()
      publishMsg.convid = convid
      hActor.h_onMessageInternal publishMsg
      publishedMessages++
      i++

  beforeEach ->
    cmd = config.makeHMessage(existingCHID, hActor.actor, "hCommand", {})
    cmd.payload =
      cmd: "hGetThread"
      params:
        convid: convid
      filter: {}

  it "should return hResult error INVALID_ATTR without params", (done) ->
    delete cmd.payload.params
    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a "string"
      done()


  it "should return hResult error INVALID_ATTR with params not an object", (done) ->
    cmd.payload.params = "string"
    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a "string"
      done()


  it "should return hResult error NOT_AUTHORIZED if the sender is not a subscriber", (done) ->
    hActor.properties.subscribers = [config.logins[2].urn]
    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.NOT_AUTHORIZED
      hMessage.payload.should.have.property('result').and.be.a('string')
      hActor.properties.subscribers = [existingCHID]
      done()


  it "should return hResult error MISSING_ATTR if actor is not provided", (done) ->
    delete cmd.actor

    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.MISSING_ATTR
      hMessage.payload.should.have.property("result").and.match /actor/
      done()


  it "should return hResult error NOT_AVAILABLE with actor not a channel", (done) ->
    hActor.createChild "hactor", "inproc", {actor: config.logins[0].urn}, (child) =>
      cmd.actor = child.actor
      child.h_onMessageInternal cmd, (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.NOT_AVAILABLE
        done()


  it "should return hResult error MISSING_ATTR if convid is not provided", (done) ->
    delete cmd.payload.params.convid

    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.MISSING_ATTR
      hMessage.payload.should.have.property("result").and.match /convid/
      done()


  it "should return hResult error INVALID_ATTR with convid not a string", (done) ->
    cmd.payload.params.convid = []
    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.match /convid/
      done()


  it "should return hResult OK with an empty [] if no messages found matching convid", (done) ->
    cmd.payload.params.convid = config.getUUID()
    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      hMessage.payload.result.should.be.an.instanceof(Array)
      hMessage.payload.result.length.should.be.equal(0);
      done()


  it "should return hResult OK with an [] containing all messages with same convid sort older to newer", (done) ->
    hActor.h_onMessageInternal cmd, (hMessage) ->
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
    hActor.h_onMessageInternal cmd, (hMessage) ->
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
    hActor.h_onMessageInternal cmd, (hMessage) ->
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
      publishMsg = config.makeHMessage existingCHID, hActor.actor, "a type", {}
      publishMsg.timeout = 0
      publishMsg.persistent = true
      publishMsg.published = new Date().getTime()
      publishMsg.convid = convid
      hActor.h_onMessageInternal publishMsg
      publishedMessages++

      i = 0
      while i < 3
        publishMsg = config.makeHMessage existingCHID, hActor.actor, "a type", {}
        publishMsg.timeout = 0
        publishMsg.persistent = true
        publishMsg.published = new Date().getTime()
        publishMsg.convid = convid2
        hActor.h_onMessageInternal publishMsg
        filterMessagesPublished++
        i++

      i = 0
      while i < 3
        publishMsg = config.makeHMessage existingCHID, hActor.actor, "another type", {}
        publishMsg.timeout = 0
        publishMsg.persistent = true
        publishMsg.published = new Date().getTime()
        publishMsg.convid = convid2
        hActor.h_onMessageInternal publishMsg
        filterMessagesPublished++
        i++

    beforeEach  ->
      cmd.payload.filter = eq:
        type: "a type"

    it "should not return msgs if a msg OTHER than the first one pass the filter", (done) ->
      hActor.h_onMessageInternal cmd, (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.OK
        hMessage.payload.result.should.be.an.instanceof(Array)
        hMessage.payload.result.length.should.be.equal(0)
        done()


    it "should return ALL convid msgs if the first one complies with the filter", (done) ->
      cmd.payload.params.convid = convid2
      hActor.h_onMessageInternal cmd, (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.OK
        hMessage.payload.result.should.be.an.instanceof(Array)
        hMessage.payload.result.length.should.be.equal(filterMessagesPublished);
        done()



