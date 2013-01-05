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

#
# NEEDS BEFORE hSubscribe
#
describe "hUnsubscribe", ->
  cmd = undefined
  hActor = undefined
  hChannel = undefined
  status = require("../lib/codes").hResultStatus
  actorModule = require("../lib/actor/hactor")
  existingCHID = "urn:localhost:#{config.getUUID()}"
  existingCHID2 = "urn:localhost:#{config.getUUID()}"

  before () ->
    topology = {
      actor: config.logins[0].urn,
      type: "hactor"
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

    properties =
      listenOn: "tcp://127.0.0.1:2112",
      broadcastOn: "tcp://127.0.0.1:8992",
      subscribers: [config.logins[0].urn],
      db:{
        dbName: "test",
        dbCollection: existingCHID2
      }
    hActor.createChild "hchannel", "inproc", {actor: existingCHID, properties: properties}, (child) =>
      hChannel = child

  after () ->
    hActor.h_tearDown()
    hActor = null

  #Subscribe to channel
  before (done) ->
    hActor.subscribe existingCHID, "",(statusCode) ->
      statusCode.should.be.equal(status.OK)
      done()

  it "should return hResult error MISSING_ATTR when actor is missing", (done) ->
    hActor.unsubscribe undefined, (statuses, result) ->
      statuses.should.be.equal(status.MISSING_ATTR)
      result.should.match(/channel/)
      done()


  it "should return hResult error NOT_AVAILABLE with actor not a channel", (done) ->
    hActor.unsubscribe hActor.actor, (statuses, result) ->
      statuses.should.be.equal(status.NOT_AVAILABLE)
      done()


  it "should return hResult NOT_AVAILABLE if not subscribed and no subscriptions", (done) ->
    hActor.unsubscribe existingCHID2, (statuses, result) ->
      statuses.should.be.equal(status.NOT_AVAILABLE)
      result.should.match(/not subscribed/)
      done()

  it "should return hResult OK when correct", (done) ->
    hActor.unsubscribe existingCHID, (statuses, result) ->
      statuses.should.be.equal(status.OK)
      done()

  describe "hUnsubscribe with quickFilter", ->
    #Subscribe to channel with quickfilter
    before (done) ->
      hActor.subscribe existingCHID, "quickfilter1",(statusCode) ->
        statusCode.should.be.equal(status.OK)
        done()

    before (done) ->
      hActor.subscribe existingCHID, "quickfilter2",(statusCode) ->
        statusCode.should.be.equal(status.OK)
        done()

    it "should return hResult OK if removed correctly a quickfilter", (done) ->
      hActor.unsubscribe existingCHID, "quickfilter1", (statuses, result) ->
        statuses.should.be.equal(status.OK)
        result.should.be.equal("QuickFilter removed")
        done()

    it "should return hResult OK if unsubscribe after removed the last quickfilter", (done) ->
      hActor.unsubscribe existingCHID, "quickfilter2", (statuses, result) ->
        statuses.should.be.equal(status.OK)
        result.should.be.equal("Unsubscribe from channel")
        done()


