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

describe "hCreateUpdateChannel", ->
  hActor = undefined
  actorModule = require("../lib/actor/hsession")
  status = require("../lib/codes").hResultStatus
  createCmd = undefined

  before () ->
    topology = {
    actor: config.logins[0].jid,
    type: "hsession"
    }
    hActor = actorModule.newActor(topology)

  after () ->
    hActor.h_tearDown()
    hActor = null

  beforeEach ->
    @timeout 5000
    createCmd = config.createChannel "##{config.getUUID()}@localhost", [config.validJID], config.validJID, true

  it "should return hResult error INVALID_ATTR without params", (done) ->
    createCmd.payload.params = null
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a "string"
      done()


  it "should return hResult error INVALID_ATTR with params not an object", (done) ->
    createCmd.payload.params = "string"
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a "string"
      done()


  it "should return hResult error MISSING_ATTR without actor", (done) ->
    delete createCmd.payload.params.actor

    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.MISSING_ATTR
      hMessage.payload.should.have.property("result").and.be.a("string").and.match /actor/i
      done()


  it "should return hResult error INVALID_ATTR with empty string as actor", (done) ->
    @timeout 5000
    createCmd.payload.params.actor = ""
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a("string").and.match /actor/i
      done()


  it "should return hResult error INVALID_ATTR with type is not 'channel'", (done) ->
    createCmd.payload.params.type = "bad_type"
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a "string"
      done()


  it "should return hResult error OK with actor with a different domain", (done) ->
    createCmd.payload.params.actor = "#channel@another.domain"
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      done()


  it "should return hResult error NOT_AUTHORIZED with using hAdminChannel as actor", (done) ->
    createCmd.payload.params.actor = "#hAdminChannel@localhost"
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.NOT_AUTHORIZED
      hMessage.payload.should.have.property("result").and.be.a "string"
      done()


  it "should return hResult error INVALID_ATTR if actor is not string castable", (done) ->
    createCmd.payload.params.actor = []
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a("string").and.match /actor/i
      done()


  it "should return hResult error INVALID_ATTR if priority is not a number", (done) ->
    createCmd.payload.params.priority = "not a number"
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a("string").and.match /priority/i
      done()


  it "should return hResult error INVALID_ATTR if priority >5", (done) ->
    createCmd.payload.params.priority = 6
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a("string").and.match /priority/i
      done()


  it "should return hResult error INVALID_ATTR if priority <0", (done) ->
    createCmd.payload.params.priority = -1
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a("string").and.match /priority/i
      done()


  it "should return hResult error INVALID_ATTR with invalid location format", (done) ->
    createCmd.payload.params.location = "something"
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      done()


  it "should return hResult error MISSING_ATTR if owner is missing", (done) ->
    delete createCmd.payload.params.owner

    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.MISSING_ATTR
      hMessage.payload.should.have.property("result").and.be.a("string").and.match /owner/i
      done()


  it "should return hResult error INVALID_ATTR if owner is an empty string", (done) ->
    createCmd.payload.params.owner = ""
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a("string").and.match /owner/i
      done()


  it "should return hResult error INVALID_ATTR if owner JID is not bare", (done) ->
    createCmd.payload.params.owner = createCmd.publisher + "/resource"
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a("string").and.match /owner/i
      done()


  it "should return hResult error MISSING_ATTR if subscribers is missing", (done) ->
    delete createCmd.payload.params.subscribers

    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.MISSING_ATTR
      hMessage.payload.should.have.property("result").and.be.a("string").and.match /subscriber/i
      done()


  it "should return hResult error INVALID_ATTR if subscribers is not an array", (done) ->
    createCmd.payload.params.subscribers = ""
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a("string").and.match /subscriber/i
      done()


  it "should return hResult error INVALID_ATTR if subscribers has an element that is not a string", (done) ->
    createCmd.payload.params.subscribers = [not: "a string"]
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a("string").and.match /subscriber/i
      done()


  it "should return hResult error INVALID_ATTR if subscribers has an element that is not a JID", (done) ->
    createCmd.payload.params.subscribers = ["a@b", "this is not a JID"]
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a("string").and.match /subscriber/i
      done()


  it "should return hResult error INVALID_ATTR if subscribers has an element that is not a bare JID", (done) ->
    createCmd.payload.params.subscribers = ["a@b", "a@b/resource"]
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a("string").and.match /subscriber/i
      done()


  it "should return hResult error MISSING_ATTR if active is missing", (done) ->
    delete createCmd.payload.params.active

    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.MISSING_ATTR
      hMessage.payload.should.have.property("result").and.be.a("string").and.match /active/i
      done()


  it "should return hResult error INVALID_ATTR if active is not a boolean", (done) ->
    createCmd.payload.params.active = "this is a string"
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a("string").and.match /active/i
      done()


  it "should return hResult error INVALID_ATTR if headers is not an object", (done) ->
    createCmd.payload.params.headers = "something"
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.INVALID_ATTR
      hMessage.payload.should.have.property("result").and.be.a("string").and.match /header/i
      done()


  it "should return hResult error NOT_AUTHORIZED if owner different than sender", (done) ->
    createCmd.payload.params.owner = "another@another.jid"
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.NOT_AUTHORIZED
      done()


  it "should return hResult OK if publisher has resource and owner doesnt", (done) ->
    @timeout 5000
    createCmd.publisher = config.validJID + "/resource"
    createCmd.payload.params.owner = config.validJID
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      done()


  it "should return hResult OK if actor is fully compliant with #chid@domain", (done) ->
    @timeout 5000
    createCmd.payload.params.actor = "#actor@localhost"
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      done()


  it "should return hResult OK without any optional attributes", (done) ->
    @timeout 5000
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      done()


  it "should return hResult ok with every attribute (including optional) correct", (done) ->
    @timeout 5000
    createCmd.payload.params.chdesc = "a"
    createCmd.payload.params.priority = 3
    createCmd.payload.params.location =
      num: "2"
      wayType: "rue"
      way: ""
      addr: ""
      floor: ""

    createCmd.payload.params.location.pos =
      lng: "s"
      lat: ""

    createCmd.payload.params.headers = key: "value"
    hActor.h_onMessageInternal createCmd, (hMessage) ->
      hMessage.should.have.property "ref", createCmd.msgid
      hMessage.payload.should.have.property "status", status.OK
      done()

  describe "#Update Channel", ->

    #Channel that will be created and updated
    existingCHID = "##{config.getUUID()}@localhost"

    before (done) ->
      @timeout 5000
      createCmd = config.createChannel existingCHID, [config.validJID], config.validJID, true
      hActor.h_onMessageInternal createCmd,  (hMessage) ->
        hMessage.should.have.property "ref", createCmd.msgid
        hMessage.payload.should.have.property "status", status.OK
        done()

    it "should return hResult ok if actor exists updating", (done) ->
      @timeout 5000
      createCmd.payload.params.actor = existingCHID
      createCmd.payload.params.subscribers = ["u2@another"]
      hActor.h_onMessageInternal createCmd, (hMessage) ->
        hMessage.should.have.property "ref", createCmd.msgid
        hMessage.payload.should.have.property "status", status.OK

        #config.db.cache.hChannels[existingCHID].subscribers.should.be.eql(createCmd.payload.params.subscribers);
        done()


    it "should return hResult OK if a new subscriber is added", (done) ->
      @timeout 5000
      createCmd.payload.params.actor = existingCHID
      createCmd.payload.params.subscribers = [config.validJID, "u2@another2"]
      hActor.h_onMessageInternal createCmd, (hMessage) ->
        hMessage.should.have.property "ref", createCmd.msgid
        hMessage.payload.should.have.property "status", status.OK
        done()


    it "should return hResult OK if an old subscriber is removed", (done) ->
      @timeout 5000
      createCmd.payload.params.actor = existingCHID
      createCmd.payload.params.subscribers = ["u2@another2"]
      hActor.h_onMessageInternal createCmd, (hMessage) ->
        hMessage.should.have.property "ref", createCmd.msgid
        hMessage.payload.should.have.property "status", status.OK
        done()


    it "should return hResult error if sender tries to update owner", (done) ->
      @timeout 5000
      createCmd.payload.params.owner = "a@jid.different"
      createCmd.payload.params.actor = existingCHID
      hActor.h_onMessageInternal createCmd, (hMessage) ->
        hMessage.should.have.property "ref", createCmd.msgid
        hMessage.payload.should.have.property "status", status.NOT_AUTHORIZED
        done()



