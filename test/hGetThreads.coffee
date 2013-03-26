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
factory = require "../lib/hfactory"

describe "hGetThreads", ->
  cmd = undefined
  hActor = undefined
  hActor2 = undefined
  status = require("../lib/codes").hResultStatus
  Channel = require "../lib/actor/hchannel"
  Actor = require "../lib/actor/hactor"
  activeChannel = "urn:localhost:#{config.getUUID()}"
  correctStatus = config.getUUID()
  convids = []
  shouldNotAppearConvids = []

  before (done) ->
    topology = {
      actor: activeChannel,
      type: "hchannel",
      properties: {
        subscribers:[activeChannel],
        listenOn: "tcp://127.0.0.1:1221",
        broadcastOn: "tcp://127.0.0.1:2998",
        db:{
          host: "localhost",
          port: 27017,
          name: "test"
        },
        collection: activeChannel.replace(/[-.]/g, "")
      }
    }
    hActor = new Channel topology
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
    hActor2 = new Actor topology

  after () ->
    hActor.h_tearDown()
    hActor = null
    hActor2.h_tearDown()
    hActor2 = null

  #Root messages with different status
  i = 0
  while i < 2
    before (done) ->
      publishMsg = config.makeHMessage activeChannel, hActor.actor, "hConvState", {status: config.getUUID()}
      publishMsg.timeout = 30000
      publishMsg.persistent = true
      publishMsg.published = new Date().getTime()
      hActor.send = (hMessage) ->
        if hMessage.type is "hResult"
          shouldNotAppearConvids.push hMessage.payload.result.convid
          done()
      hActor.h_onMessageInternal publishMsg
    i++
  i = 0

  #Change state of one of the previous convstate to a good one
  before (done) ->
    publishMsg = config.makeHMessage activeChannel, hActor.actor, "hConvState", {status: correctStatus}
    publishMsg.timeout = 30000
    publishMsg.persistent = true
    publishMsg.published = new Date().getTime()
    publishMsg.convid = shouldNotAppearConvids.pop()
    hActor.send = (hMessage) ->
      if hMessage.type is "hResult"
        hMessage.payload.should.have.property "status", status.OK
        publishMsg2 = config.makeHMessage activeChannel, hActor.actor, "string", {}
        publishMsg2.timeout = 0
        publishMsg2.persistent = true
        publishMsg2.published = new Date().getTime()
        publishMsg2.priority = 3
        publishMsg2.convid = hMessage.payload.result.convid
        hActor.h_onMessageInternal publishMsg2
        convids.push hMessage.payload.result.convid
        done()
    hActor.h_onMessageInternal publishMsg

  #Add a new conversation with good status
  before (done) ->
    publishMsg = config.makeHMessage activeChannel, hActor.actor, "hConvState", {status: correctStatus}
    publishMsg.timeout = 30000
    publishMsg.persistent = true
    publishMsg.published = new Date().getTime()
    hActor.send = (hMessage) ->
      if hMessage.type is "hResult"
        hMessage.payload.should.have.property "status", status.OK
        publishMsg2 = config.makeHMessage activeChannel, hActor.actor, "string", {}
        publishMsg2.timeout = 0
        publishMsg2.persistent = true
        publishMsg2.published = new Date().getTime()
        publishMsg2.convid = hMessage.payload.result.convid
        hActor.h_onMessageInternal publishMsg2
        convids.push hMessage.payload.result.convid
        done()
    hActor.h_onMessageInternal publishMsg

  beforeEach ->
    cmd = config.makeHMessage(activeChannel, hActor.actor, "hCommand", {})
    cmd.payload =
      cmd: "hGetThreads"
      params:
        status: correctStatus
      filter: {}

  it "should return hResult error INVALID_ATTR without params", (done) ->
    cmd.payload.params = null
    hActor.send = (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a "string"
      done()

    hActor.h_onMessageInternal cmd


  it "should return hResult error INVALID_ATTR with params not an object", (done) ->
    cmd.payload.params = "string"
    hActor.send = (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a "string"
      done()

    hActor.h_onMessageInternal cmd


  it "should return hResult error NOT_AUTHORIZED if the publisher is not a subscriber", (done) ->
    hActor.properties.subscribers = [config.logins[2].urn]
    hActor.send = (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.NOT_AUTHORIZED
      hMessage.payload.should.have.property('result').and.be.a('string')
      hActor.properties.subscribers = [activeChannel]
      done()

    hActor.h_onMessageInternal cmd


  it "should return hResult error MISSING_ATTR if actor is not provided", (done) ->
    delete cmd.actor

    hActor.send = (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.MISSING_ATTR
      hMessage.payload.should.have.property("result").and.match /actor/
      done()

    hActor.h_onMessageInternal cmd


  it "should return hResult error INVALID_ATTR with actor not a channel", (done) ->
    cmd.actor = hActor2.actor
    hActor2.send = (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.NOT_AVAILABLE
      done()

    hActor2.h_onMessageInternal cmd


  it "should return hResult error MISSING_ATTR if status is not provided", (done) ->
    delete cmd.payload.params.status

    hActor.send = (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.MISSING_ATTR
      hMessage.payload.should.have.property("result").and.match /status/
      done()

    hActor.h_onMessageInternal cmd


  it "should return hResult error INVALID_ATTR with status not a string", (done) ->
    cmd.payload.params.status = []
    hActor.send = (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.match /status/
      done()

    hActor.h_onMessageInternal cmd


  it "should return hResult OK with an empty [] if no messages found matching status", (done) ->
    cmd.payload.params.status = config.getUUID()
    hActor.send = (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      hMessage.payload.result.should.be.an.instanceof(Array)
      hMessage.payload.result.length.should.be.equal(0)
      done()

    hActor.h_onMessageInternal cmd


  it "should return hResult OK with an [] containing convids whose convstate status is equal to the sent one", (done) ->
    hActor.send = (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      hMessage.payload.result.should.be.an.instanceof(Array)
      hMessage.payload.result.length.should.be.equal(convids.length)
      done()

    hActor.h_onMessageInternal cmd


  it "should return hResult OK with an [] without convid that was equal to the one sent but is not anymore", (done) ->
    hActor.send = (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      i = 0

      while i < shouldNotAppearConvids.length
        hMessage.payload.result.should.not.include shouldNotAppearConvids[i]
        i++
      done()

    hActor.h_onMessageInternal cmd


  describe "#FilterMessage()", ->
    it "should only return convids of filtered conversations", (done) ->
      cmd.payload.filter = eq :
        priority: 3
      hActor.send = (hMessage) ->
        hMessage.should.have.property "ref", cmd.msgid
        hMessage.payload.should.have.property "status", status.OK
        hMessage.payload.result.should.be.an.instanceof(Array)
        hMessage.payload.result.length.should.be.equal(1)
        done()

      hActor.h_onMessageInternal cmd