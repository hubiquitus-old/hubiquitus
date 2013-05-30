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
factory = require "../lib/hfactory"
validator = require "../lib/validator.coffee"

describe "hHttpAdapter", ->
  hActor = undefined
  config = require("./_config")
  hResultStatus = require("../lib/codes").hResultStatus
  Actor = require "../lib/actors/hactor"

  describe "Http_inbound", ->
    http = require "http"

    before () ->
      topology = {
      actor: "urn:localhost:actor",
      type: "hactor",
      properties: {},
      adapters: [ { type: "http_in", url: "http://127.0.0.1:8888" } ]
      }
      hActor = new Actor topology
      hActor.h_onMessageInternal(hActor.h_buildSignal(hActor.actor, "start", {}))

    after () ->
      hActor.h_tearDown()
      hActor = null

    it "should receive the http POST request", (done) ->
      myHMessage = JSON.stringify(hActor.buildMessage(hActor.actor, "hHttpMessage", {goodBye:'worldPOST'}, {headers:{ 'host: "127.0.0.1:8888",
                     connection: "keep-alive",
                     transfer-encoding: "chunked"' }}))

      hActor.onMessage = (hMessage) ->
        hMessage.type.should.be.equal('hHttpMessage')
        hMessage.should.have.property("headers").and.be.an.instanceOf(Object)
        hMessage.should.have.property("payload").and.be.an.instanceOf(Object)
        done()

      options =
        hostname: "127.0.0.1"
        port: 8888
        path: '/'
        method: 'POST'

      req = http.request options, (res) ->

      req.write myHMessage

      req.end()

    it "should receive the http GET request", (done) ->
      myHMessage = JSON.stringify(hActor.buildMessage(hActor.actor, "hHttpMessage", {goodBye:'worldGET'}, {headers:{ 'host: "127.0.0.1:8888",
                           connection: "keep-alive",
                           transfer-encoding: "chunked"' }}))
      hActor.onMessage = (hMessage) ->
        hMessage.type.should.be.equal('hHttpMessage')
        hMessage.should.have.property("headers").and.be.an.instanceOf(Object)
        hMessage.should.have.property("payload").and.be.an.instanceOf(Object)
        done()

      options =
        hostname: "127.0.0.1"
        port: 8888
        path: '/hmessage='+myHMessage.replace(/\s/g, '');
      http.get options, (res) ->


  describe "Http_outbound", ->
    http = require "http"
    qs = require "querystring"

    before () ->
      topology = {
        actor: "urn:localhost:actor",
        type: "hactor",
        properties: {},
        adapters: [ {type: "http_out", url: "127.0.0.1", targetActorAid :"urn:localhost:httpOutMochaTest" ,path: "/" ,port: 8989 } ]
      }
      hActor = new Actor(topology)
      hActor.h_onMessageInternal(hActor.h_buildSignal(hActor.actor, "start", {}))

    after () ->
      hActor.h_tearDown()
      hActor = null

    it "should send http request", (done) ->
      server = http.createServer (req, res) =>
        body = undefined
        req.on "data", (data) ->
          body = data
        req.on "end", =>
          result = validator.validateHMessage JSON.parse( body.toString('utf8') )
          unless result.valid
            console.log "hMessage not conform : " + JSON.stringify(result)
            #@owner.log "hMessage not conform : " + JSON.stringify(result)
          else
            done()



      server.listen 8989, "127.0.0.1"
      hActor.send hActor.buildMessage("urn:localhost:httpOutMochaTest", "hHttpMessage", {hello:"world"})




