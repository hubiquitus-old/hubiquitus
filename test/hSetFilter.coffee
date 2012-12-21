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
describe "hSetFilter", ->
  hActor = undefined
  config = require("./_config")
  hResultStatus = require("../lib/codes").hResultStatus
  cmd = {}
  actorModule = require("../lib/actor/hsession")

  before () ->
    topology = {
    actor: config.logins[0].urn,
    type: "hsession"
    }
    hActor = actorModule.newActor(topology)

  after () ->
    hActor.h_tearDown()

  beforeEach ->
    cmd = config.makeHMessage(hActor.actor, config.logins[0].urn, "hCommand", {})
    cmd.msgid = "testCmd"
    cmd.payload =
      cmd: "hSetFilter"
      params: {}

  it "should return hResult OK if params filter is empty", (done) ->
    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", hResultStatus.OK
      done()


  it "should return hResult INVALID_ATTR if params filter is not an object", (done) ->
    cmd.payload.params = "a string"
    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", hResultStatus.INVALID_ATTR
      done()


  it "should return hResult INVALID_ATTR if filter does not start with a correct operand", (done) ->
    cmd.payload.params = bad:
      attribut: true

    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", hResultStatus.INVALID_ATTR
      hMessage.payload.should.have.property "result", "A filter must start with a valid operand"
      done()


  it "should return hResult INVALID_ATTR if filter with operand eq/ne/lt/lte/gt/gte/in/nin is not an object", (done) ->
    cmd.payload.params =
      eq: "string"
      ne: "string"
      lt: "string"
      lte: "string"
      gt: "string"
      gte: "string"
      in: "string"
      nin: "string"

    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", hResultStatus.INVALID_ATTR
      hMessage.payload.should.have.property "result", "The attribute of an operand eq must be an object"
      done()


  it "should return hResult INVALID_ATTR if filter with operand and/or/nor is not an array", (done) ->
    cmd.payload.params =
      and:
        attribut: false

      or:
        attribut: false

      nor:
        attribut: false

    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", hResultStatus.INVALID_ATTR
      hMessage.payload.should.have.property "result", "The attribute must be an array with at least 2 elements"
      done()


  it "should return hResult INVALID_ATTR if filter with operand and/or/nor is an array of 1 element", (done) ->
    cmd.payload.params =
      and: [attribut: false]
      or: [attribut: false]
      nor: [attribut: false]

    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", hResultStatus.INVALID_ATTR
      hMessage.payload.should.have.property "result", "The attribute must be an array with at least 2 elements"
      done()


  it "should return hResult INVALID_ATTR if filter with operand not is an valid object", (done) ->
    cmd.payload.params = not: [attribut: false]
    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", hResultStatus.INVALID_ATTR
      hMessage.payload.should.have.property "result", "The attribute of an operand \"not\" must be an object"
      done()


  it "should return hResult INVALID_ATTR if filter with operand \"not\" not contain valid operand", (done) ->
    cmd.payload.params = not:
      bad:
        attribut: false

    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", hResultStatus.INVALID_ATTR
      hMessage.payload.should.have.property "result", "A filter must start with a valid operand"
      done()


  it "should return hResult INVALID_ATTR if filter with operand relevant is not a boolean", (done) ->
    cmd.payload.params = relevant: "string"
    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", hResultStatus.INVALID_ATTR
      hMessage.payload.should.have.property "result", "The attribute of an operand \"relevant\" must be a boolean"
      done()


  it "should return hResult INVALID_ATTR if filter with operand geo have not attribut radius", (done) ->
    cmd.payload.params = geo:
      lat: 12
      lng: 24

    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", hResultStatus.INVALID_ATTR
      hMessage.payload.should.have.property "result", "Attributes of an operand \"geo\" must be numbers"
      done()


  it "should return hResult INVALID_ATTR if filter with operand geo have not attribut lat", (done) ->
    cmd.payload.params = geo:
      lng: 24
      radius: 10000

    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", hResultStatus.INVALID_ATTR
      hMessage.payload.should.have.property "result", "Attributes of an operand \"geo\" must be numbers"
      done()


  it "should return hResult INVALID_ATTR if filter with operand geo have not attribut lng", (done) ->
    cmd.payload.params = geo:
      lat: 12
      radius: 10000

    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", hResultStatus.INVALID_ATTR
      hMessage.payload.should.have.property "result", "Attributes of an operand \"geo\" must be numbers"
      done()


  it "should return hResult INVALID_ATTR if attribut lat of filter geo is not a number", (done) ->
    cmd.payload.params = geo:
      lat: "string"
      lng: 24
      radius: 10000

    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", hResultStatus.INVALID_ATTR
      hMessage.payload.should.have.property "result", "Attributes of an operand \"geo\" must be numbers"
      done()


  it "should return hResult INVALID_ATTR if attribut lng of filter geo is not a number", (done) ->
    cmd.payload.params = geo:
      lat: 12
      lng: "string"
      radius: 10000

    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", hResultStatus.INVALID_ATTR
      hMessage.payload.should.have.property "result", "Attributes of an operand \"geo\" must be numbers"
      done()


  it "should return hResult INVALID_ATTR if attribut lat of filter geo is not a number", (done) ->
    cmd.payload.params = geo:
      lat: 12
      lng: 24
      radius: "string"

    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "ref", cmd.msgid
      hMessage.payload.should.have.property "status", hResultStatus.INVALID_ATTR
      hMessage.payload.should.have.property "result", "Attributes of an operand \"geo\" must be numbers"
      done()


  it "should return INVALID_ATTR if attribute boolean is not a boolean", (done) ->
    cmd.payload.params = boolean: "string"
    hActor.h_onMessageInternal cmd, (hMessage) ->
      hMessage.should.have.property "type", "hResult"
      hMessage.payload.should.have.property "status", hResultStatus.INVALID_ATTR
      done()


