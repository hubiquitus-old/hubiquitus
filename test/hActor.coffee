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
_ = require "underscore"

describe "hActor", ->
  hActor = undefined
  hActor2 = undefined
  config = require("./_config")
  hResultStatus = require("../lib/codes").hResultStatus
  Actor = require("../lib/actors/hactor")

  describe "#FilterMessage()", ->
    hMsg = undefined
    filter = undefined

    before () ->
      topology = {
        actor: config.logins[0].urn,
        type: "hactor"
      }
      hActor = new Actor(topology)
      hActor.onMessage = (hMessage) ->
        if hMessage.timeout > 0
          hMessageResult = @buildResult(hMessage.publisher, hMessage.msgid, hResultStatus.OK, "")
          @send hMessageResult

    after () ->
      hActor.h_tearDown()
      hActor = null

    beforeEach ->
      filter = {}
      hMsg = config.makeHMessage(hActor.actor, config.logins[0].urn, "string", {})

    it "should return Ok if empty filter", (done) ->
      hActor.send = (hMessage) ->
        hMessage.should.have.property "type", "hResult"
        hMessage.payload.should.have.property "status", hResultStatus.OK
        done()

      hActor.h_onMessageInternal hMsg

    describe "#eqFilter()", ->
      it "should not respond if hMessage doesn't respect \"eq\" filter", (done) ->
        filter = eq:
          priority: 2

        hMsg.priority = 3
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if a bad attribute of hMessage is use", (done) ->
        filter = eq:
          attribut: "bad"

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if hMessage don't respect \"eq\" filter with multiple hCondition", (done) ->
        filter = eq:
          priority: 2
          author: config.logins[0].urn

        hMsg.priority = 2
        hMsg.author = config.logins[1].urn
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return OK if hMessage respect \"eq\" filter with multiple hCondition", (done) ->
        filter = eq:
          priority: 2
          author: config.logins[0].urn

        hMsg.priority = 2
        hMsg.author = config.logins[0].urn
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg

      it "should return OK if hMessage respect \"eq\" filter ", (done) ->
        filter = eq:
          "payload.priority": 2

        hMsg.payload.priority = 2
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg


    describe "#neFilter()", ->
      it "should return an error message if hMessage don't respect \"ne\" filter", (done) ->
        filter = ne:
          priority: 2

        hMsg.priority = 2
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if a bad attribute of hMessage is use", (done) ->
        filter = ne:
          attribut: "bad"

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if hMessage don't respect \"ne\" filter with multiple hCondition", (done) ->
        filter = ne:
          priority: 2
          author: config.logins[0].urn

        hMsg.priority = 3
        hMsg.author = config.logins[0].urn
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return OK if hMessage respect \"ne\" filter with multiple hCondition", (done) ->
        filter = ne:
          priority: 2
          author: config.logins[0].urn

        hMsg.priority = 3
        hMsg.author = config.logins[1].urn
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg

      it "should return OK if hMessage respect \"ne\" filter ", (done) ->
        filter = ne:
          "payload.priority": 2

        hMsg.payload.priority = 3
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg


    describe "#gtFilter()", ->
      it "should return an error message if hMessage don't respect \"gt\" filter", (done) ->
        filter = gt:
          priority: 2

        hMsg.priority = 2
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if a bad attribute of hMessage is use", (done) ->
        filter = gt:
          attribut: 12

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if an attribute is not a number", (done) ->
        filter = gt:
          priority: "not a number"

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if hMessage don't respect \"gt\" filter with multiple hCondition", (done) ->
        filter = gt:
          priority: 2
          timeout: 10000

        hMsg.priority = 3
        hMsg.timeout = 9999
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return OK if hMessage respect \"gt\" filter with multiple hCondition", (done) ->
        filter = gt:
          priority: 2
          timeout: 10000

        hMsg.priority = 3
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg

      it "should return OK if hMessage respect \"gt\" filter ", (done) ->
        filter = gt:
          "payload.priority": 2

        hMsg.payload.priority = 3
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg


    describe "#gteFilter()", ->
      it "should return an error message if hMessage don't respect \"gte\" filter", (done) ->
        filter = gte:
          priority: 2

        hMsg.priority = 1
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if a bad attribute of hMessage is use", (done) ->
        filter = gte:
          attribut: 12

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if an attribute is not a number", (done) ->
        filter = gte:
          priority: "not a number"

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if hMessage don't respect \"gte\" filter with multiple hCondition", (done) ->
        filter = gte:
          priority: 2
          timeout: 10000

        hMsg.priority = 2
        hMsg.timeout = 9999
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return OK if hMessage respect \"gte\" filter with multiple hCondition", (done) ->
        filter = gte:
          priority: 2
          timeout: 10000

        hMsg.priority = 2
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg

      it "should return OK if hMessage respect \"gte\" filter ", (done) ->
        filter = gte:
          "payload.params.priority": 2

        hMsg.payload.params = {}
        hMsg.payload.params.priority = 2
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg


    describe "#ltFilter()", ->
      it "should return an error message if hMessage don't respect \"lt\" filter", (done) ->
        filter = lt:
          priority: 2

        hMsg.priority = 3
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if a bad attribute of hMessage is use", (done) ->
        filter = lt:
          attribut: 12

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if an attribute is not a number", (done) ->
        filter = lt:
          priority: "not a number"

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if hMessage don't respect \"lt\" filter with multiple hCondition", (done) ->
        filter = lt:
          priority: 2
          timeout: 10000

        hMsg.priority = 2
        hMsg.timeout = 10001
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return OK if hMessage respect \"lt\" filter with multiple hCondition", (done) ->
        filter = lt:
          priority: 2
          timeout: 10000

        hMsg.priority = 1
        hMsg.timeout = 9999
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg

      it "should return OK if hMessage respect \"lt\" filter ", (done) ->
        filter = lt:
          "payload.params.priority": 2

        hMsg.payload.params = {}
        hMsg.payload.params.priority = 1
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg


    describe "#lteFilter()", ->
      it "should return an error message if hMessage don't respect \"lte\" filter", (done) ->
        filter = lte:
          priority: 2

        hMsg.priority = 3
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if a bad attribute of hMessage is use", (done) ->
        filter = lte:
          attribut: 12

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if an attribute is not a number", (done) ->
        filter = lte:
          priority: "not a number"

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if hMessage don't respect \"lte\" filter with multiple hCondition", (done) ->
        filter = lte:
          priority: 2
          timeout: 10000

        hMsg.priority = 1
        hMsg.timeout = 10001
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return OK if hMessage respect \"lte\" filter with multiple hCondition", (done) ->
        filter = lte:
          priority: 2
          timeout: 10000

        hMsg.priority = 1
        hMsg.timeout = 10000
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg

      it "should return OK if hMessage respect \"lte\" filter ", (done) ->
        filter = lte:
          "payload.params.priority": 2

        hMsg.payload.params = {}
        hMsg.payload.params.priority = 2
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg


    describe "#inFilter()", ->
      it "should return an error message if hMessage don't respect \"in\" filter", (done) ->
        filter = in:
          publisher: ["urn:localhost:u2", "urn:localhost:u3"]

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if a bad attribute of hMessage is use", (done) ->
        filter = in:
          attribut: "bad"

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if the attribute is not a array", (done) ->
        filter = in:
          publisher: "urn:localhost:u1"

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if hMessage don't respect \"in\" filter with multiple hCondition", (done) ->
        filter = in:
          publisher: ["urn:localhost:u1"]
          author: ["urn:localhost:u2"]

        hMsg.author = "urn:localhost:u1"
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return OK if hMessage respect \"in\" filter with multiple hCondition", (done) ->
        filter = in:
          publisher: ["urn:localhost:u1"]
          author: ["urn:localhost:u2"]

        hMsg.author = "urn:localhost:u2"
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg

      it "should return OK if hMessage respect \"in\" filter ", (done) ->
        filter = in:
          "payload.params.priority": [2, 3]

        hMsg.payload.params = {}
        hMsg.payload.params.priority = 2
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg


    describe "#ninFilter()", ->
      it "should return an error message if hMessage don't respect \"nin\" filter", (done) ->
        filter = nin:
          publisher: ["urn:localhost:u2", "urn:localhost:u1"]

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if a bad attribute of hMessage is use", (done) ->
        filter = nin:
          attribut: ["urn:localhost:u2", "urn:localhost:u1"]

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if the attribute is not a array", (done) ->
        filter = nin:
          publisher: "urn:localhost:u2"

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if hMessage don't respect \"nin\" filter with multiple hCondition", (done) ->
        filter = nin:
          publisher: ["urn:localhost:u2"]
          author: ["urn:localhost:u1"]

        hMsg.author = "urn:localhost:u1"
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return OK if hMessage respect \"nin\" filter with multiple hCondition", (done) ->
        filter = nin:
          publisher: ["urn:localhost:u2"]
          author: ["urn:localhost:u1"]

        hMsg.author = "urn:localhost:u2"
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg

      it "should return OK if hMessage respect \"nin\" filter ", (done) ->
        filter = nin:
          "payload.params.priority": [2, 3]

        hMsg.payload.params = {}
        hMsg.payload.params.priority = 4
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg


    describe "#andFilter()", ->
      it "should return an error message if hMessage don't respect \"and\" filter", (done) ->
        filter = and: [
          in:
            publisher: ["urn:localhost:u2", "urn:localhost:u1"]
        ,
          nin:
            author: ["urn:localhost:u2", "urn:localhost:u1"]
        ]
        hMsg.author = "urn:localhost:u1"
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if a bad attribute of hMessage is use", (done) ->
        filter = and: [
          in:
            publisher: ["urn:localhost:u2", "urn:localhost:u1"]
        ,
          nin:
            attribut: ["urn:localhost:u2", "urn:localhost:u1"]
        ]
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return OK if hMessage respect \"and\" filter with multiple hCondition", (done) ->
        filter = and: [
          in:
            publisher: ["urn:localhost:u2", "urn:localhost:u1"]
        ,
          nin:
            author: ["urn:localhost:u2", "urn:localhost:u1"]
        ]
        hMsg.author = "urn:localhost:u3"
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg

      it "should return OK if hMessage respect \"and\" filter ", (done) ->
        filter = and: [
          eq:
            "payload.params.priority": 2
        ,
          nin:
            author: ["urn:localhost:u2", "urn:localhost:u1"]
        ]
        hMsg.author = "urn:localhost:u3"
        hMsg.payload.params = {}
        hMsg.payload.params.priority = 2
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg


    describe "#orFilter()", ->
      it "should return an error message if hMessage don't respect \"or\" filter", (done) ->
        filter = or: [
          in:
            publisher: ["urn:localhost:u2", "urn:localhost:u3"]
        ,
          nin:
            author: ["urn:localhost:u2", "urn:localhost:u1"]
        ]
        hMsg.author = "urn:localhost:u1"
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if a bad attribute of hMessage is use", (done) ->
        filter = or: [
          in:
            publisher: ["urn:localhost:u2", "urn:localhost:u3"]
        ,
          nin:
            attribut: ["urn:localhost:u2", "urn:localhost:u1"]
        ]
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return OK if hMessage respect \"or\" filter with multiple hCondition", (done) ->
        filter = or: [
          in:
            publisher: ["urn:localhost:u2", "urn:localhost:u1"]
        ,
          nin:
            author: ["urn:localhost:u2", "urn:localhost:u1"]
        ]
        hMsg.author = "urn:localhost:u1"
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg

      it "should return OK if hMessage respect \"or\" filter ", (done) ->
        filter = or: [
          eq:
            "payload.params.priority": 2
        ,
          nin:
            author: ["urn:localhost:u2", "urn:localhost:u1"]
        ]
        hMsg.author = "urn:localhost:u3"
        hMsg.payload.params = {}
        hMsg.payload.params.priority = 3
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg


    describe "#norFilter()", ->
      it "should return an error message if hMessage don't respect \"nor\" filter", (done) ->
        filter = nor: [
          in:
            publisher: ["urn:localhost:u2", "urn:localhost:u3"]
        ,
          nin:
            author: ["urn:localhost:u2", "urn:localhost:u1"]
        ]
        hMsg.author = "urn:localhost:u3"
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return OK if hMessage respect \"nor\" filter with multiple hCondition", (done) ->
        filter = nor: [
          in:
            publisher: ["urn:localhost:u2", "urn:localhost:u3"]
        ,
          nin:
            author: ["urn:localhost:u2", "urn:localhost:u1"]
        ]
        hMsg.author = "urn:localhost:u1"
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg

      it "should return OK if hMessage respect \"nor\" filter ", (done) ->
        filter = nor: [
          eq:
            "payload.params.priority": 2
        ,
          nin:
            author: ["urn:localhost:u2", "urn:localhost:u1"]
        ]
        hMsg.author = "urn:localhost:u2"
        hMsg.payload.params = {}
        hMsg.payload.params.priority = 3
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg


    describe "#notFilter()", ->
      it "should return an error message if hMessage don't respect \"not\" filter", (done) ->
        filter = not:
          in:
            publisher: ["urn:localhost:u2", "urn:localhost:u1"]

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if hMessage don't respect \"not\" filter with multiple hCondition", (done) ->
        filter = not:
          in:
            publisher: ["urn:localhost:u2", "urn:localhost:u1"]

          eq:
            priority: 2

        hMsg.priority = 2
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return OK if hMessage respect \"not\" filter with multiple hCondition", (done) ->
        filter = not:
          in:
            publisher: ["urn:localhost:u2", "urn:localhost:u3"]

          nin:
            author: ["urn:localhost:u2", "urn:localhost:u1"]

        hMsg.author = "urn:localhost:u2"
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg

      it "should return OK if hMessage respect \"not\" filter ", (done) ->
        filter = not:
          eq:
            "payload.params.priority": 2

          in:
            author: ["urn:localhost:u2", "urn:localhost:u1"]

        hMsg.author = "urn:localhost:u3"
        hMsg.payload.params = {}
        hMsg.payload.params.priority = 3
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg

    describe "#geoFilter()", ->
      it "should return an error message if hMessage don't respect \"geo\" filter", (done) ->
        filter = geo:
          lat: 12
          lng: 24
          radius: 10000

        hMsg.location = {}
        hMsg.location.pos =
          lat: 24
          lng: 12

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if attribut radius is missing in filter", (done) ->
        filter = geo:
          lat: 12
          lng: 24

        hMsg.location = {}
        hMsg.location.pos =
          lat: 24
          lng: 12

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.INVALID_ATTR)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if attribut lat/lng is not a number", (done) ->
        filter = geo:
          lat: 24
          lng: "NaN"
          radius: 10000

        hMsg.location = {}
        hMsg.location.pos =
          lat: 24
          lng: 12

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.INVALID_ATTR)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return an error message if attribut lat/lng of hMessage is not a number", (done) ->
        filter = geo:
          lat: 24
          lng: 12
          radius: 10000

        hMsg.location = {}
        hMsg.location.pos =
          lat: 12
          lng: "NaN"

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return OK if hMessage respect \"geo\" filter", (done) ->
        filter = geo:
          lat: 23.01
          lng: 12
          radius: 10000

        hMsg.location = {}
        hMsg.location.pos =
          lat: 23
          lng: 12

        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg

    describe "#booleanFilter()", ->
      it "should return an error message if filter boolean = false", (done) ->
        filter = boolean: false
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return OK if filter boolean = true", (done) ->
        filter = boolean: true
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg

    describe "#domainFilter()", ->
      it "should return an error message if hMessage don't respect \"domain\" filter", (done) ->
        filter = domain: "domain"
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        msgSent = 0
        hActor.send = (hMessage) ->
          msgSent++

        hActor.h_onMessageInternal hMsg

        setTimeout( ->
          msgSent.should.be.eql 0
          done()
        , 100)

      it "should return OK if hMessage respect \"domain\" filter", (done) ->
        filter = domain: "localhost"
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg

      it "should return OK if hMessage respect \"domain\" filter with '$mydomain'", (done) ->
        filter = domain: "$mydomain"
        hActor.setFilter filter, (status) ->
          status.should.be.equal(hResultStatus.OK)

        hActor.send = (hMessage) ->
          hMessage.should.have.property "type", "hResult"
          hMessage.payload.should.have.property "status", hResultStatus.OK
          done()

        hActor.h_onMessageInternal hMsg

  describe "sharedProperties", ->
    actorChild = undefined
    before () ->
      topology = {
        actor: config.logins[0].urn,
        type: "hactor",
        sharedProperties: {
          v1: "s1",
          v2: "s2",
          v4: "s4"
        },
        properties: {
          v2: "p2",
          v3: "p3"
        }

      }
      hActor = new Actor(topology)
      childProp = {
        actor: config.logins[2].urn,
        type: "hactor",
        properties: {
          v2: "c2",
          v3: "c3"
        },
        sharedProperties: {v4: "t4"}
      }
      hActor.createChild "hactor", "inproc", childProp, (err, child) =>
        actorChild = child

    after () ->
      hActor.h_tearDown()
      hActor = null

    it "parent should have the sharedProperty v1 specified in topology in his properties", (done) ->
      hActor.properties.should.have.property "v1", "s1"
      done()
    it "parent should have property v2 value specified in \"properties\" rather than the one specified in \"sharedProperties\"", (done) ->
      hActor.properties.should.have.property "v2", "p2"
      done()
    it "child should inherit prop v1 from his parent", (done) ->
      actorChild.properties.should.have.property "v1", "s1"
      done()
    it "child should have v2 value specified in his own topology rather than the one specified in his parent's sharedProperties", (done) ->
      actorChild.properties.should.have.property "v2", "c2"
      done()
    it "child should have v4 value specified in his own sharedProperties rather than the one specified in his parent's sharedProperties", (done) ->
      actorChild.properties.should.have.property "v4", "t4"
      done()


  describe "#IP()", ->
    child1 = undefined
    child2 = undefined
    before () ->
      topology =
        actor: config.logins[0].urn
        type: "hactor"
        adapters: [
          {
            type: "socket_in"
          },
          {
            type: "channel_out", targetActorAid: config.logins[0].urn
          }
        ]
      hActor = new Actor(topology)

      hActor.createChild "hactor", "inproc", { actor: "urn:localhost:child1", type: "hactor", ip:"127.0.0.1" }, (err, child) =>
        child1 = child

      child1.createChild "hactor", "inproc", { actor: "urn:localhost:child2", type: "hactor" }, (err, child) =>
        child2 = child

    after () ->
      hActor.h_tearDown()
      hActor = null

    it "should have class variable 'ip' with correct value", (done) ->
      hActor.ip.should.match /^[1-2]?[0-9]{1,2}\.[1-2]?[0-9]{1,2}\.[1-2]?[0-9]{1,2}\.[1-2]?[0-9]{1,2}/
      child1.ip.should.be.equal("127.0.0.1")
      child2.ip.should.be.equal(child1.ip)
      done()

    it "should use is ip class for his adapters", (done) ->
      adapterIP = (hActor.inboundAdapters[0].url.match /^tcp:\/\/(.*):[0-9]+/)[1]
      adapterIP.should.be.equal hActor.ip

      adapter = _.find hActor.outboundAdapters, (outbound) =>
        outbound.type is "channel_out"
      adapterIP2 = (adapter.url.match /^tcp:\/\/(.*):[0-9]+/)[1]
      adapterIP2.should.be.equal hActor.ip
      done()
