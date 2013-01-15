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

describe "hSession", ->
  hActor = undefined
  hChannel = undefined
  status = require("../lib/codes").hResultStatus
  actorModule = require("../lib/actor/hsession")
  existingCHID = "urn:localhost:#{config.getUUID()}"

  before () ->
    topology = {
      actor: config.logins[0].urn,
      type: "hsession"
    }
    hActor = actorModule.newActor(topology)

    properties =
      listenOn: "tcp://127.0.0.1:1221",
      broadcastOn: "tcp://127.0.0.1:2998",
      subscribers: [config.logins[0].urn],
      db:{
        dbName: "test",
        dbCollection: existingCHID
      }
    hActor.createChild "hchannel", "inproc", {actor: existingCHID, properties: properties}, (child) =>
      hChannel = child

  before () ->
    hActor.subscribe existingCHID, "", (statuses, result) ->
      statuses.should.be.equal(status.OK)
      done()

  after () ->
    hActor.h_tearDown()
    hActor = null

  it "should emit result echoing input", (done) ->
    echoCmd = hActor.buildCommand("session", "hEcho", {hello: "world"})
    hActor.h_onMessageInternal echoCmd, (hMessage) ->
      should.exist hMessage.payload.status
      should.exist hMessage.payload.result
      hMessage.payload.status.should.be.equal status.OK
      hMessage.payload.result.should.be.equal echoCmd.payload.params
      done()

  it "should return hResult OK and filter attribut must be set", (done) ->
    setCmd = hActor.buildCommand("session", "hSetFilter", {eq:{publisher:config.logins[0].urn}})
    hActor.h_onMessageInternal setCmd, (hMessage) ->
      hMessage.should.have.property "ref", setCmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      hActor.filter.should.have.property('eq')
      done()


  it "should return hResult ok with an array as result if user has subscriptions", (done) ->
    getSubsCmd = hActor.buildCommand("session", "hGetSubscriptions", {})
    hActor.h_onMessageInternal getSubsCmd, (hMessage) ->
      hMessage.should.have.property('ref', getSubsCmd.msgid)
      hMessage.payload.should.have.property "status", status.OK
      hMessage.payload.should.have.property('result').and.be.an.instanceof(Array)
      hMessage.payload.result.length.should.be.equal(1)
      done();


  it "should return hResult OK when correctly unsubscribe", (done) ->
    unSubCmd = hActor.buildCommand("session", "hUnsubscribe", existingCHID)
    hActor.h_onMessageInternal unSubCmd, (hMessage) ->
      hMessage.should.have.property "ref", unSubCmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      hActor.getSubscriptions().length.should.be.equal(0)
      done()


  it "should return hResult NOT_AVAILABLE when unknow command is send", (done) ->
    otherCmd = hActor.buildCommand("session", "hOtherCommand", {})
    hActor.h_onMessageInternal otherCmd, (hMessage) ->
      hMessage.should.have.property('ref', otherCmd.msgid)
      hMessage.payload.should.have.property "status", status.NOT_AVAILABLE
      hMessage.payload.should.have.property('result').and.match(/Command not available/)
      done();

