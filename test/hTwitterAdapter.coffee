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

describe "hTwitterAdapter", ->
  hActor = undefined
  config = require("./_config")
  hResultStatus = require("../lib/codes").hResultStatus
  Actor = require "../lib/actors/hactor"
  newProperties = {}

  describe "Receive tweet", ->
    before () ->
      topology = {
      actor: "urn:localhost:actor",
      type: "hactor",
      properties: {},
      adapters: [
        {
          type: "twitter_in",
          properties: {
            name: "twitter",
            consumerKey: "supkCU9BZjUifb22xJYWw",
            proxy: "http://192.168.102.84:3128",
            consumerSecret: "U2zbZforgtzuBD26pmG6en946VtTD237HfcK6xho",
            twitterAccesToken: "1570147814-BK0CkD6ocLht1CdHgvxZrHhh1am3GHToWoVBQCj",
            twitterAccesTokenSecret: "YqQnyESoiMJHgOYwO8JgdwnLCcNHmpNpuHmi5krJy4",
            tags:"",
            accounts:"",
            locations: ""
          }
        } ]
      }
      hActor = new Actor topology
      msg = hActor.h_buildSignal(hActor.actor, "start", {})
      msg.sent = new Date().getTime()
      hActor.h_onMessageInternal(msg)

    beforeEach () ->


    after () ->
      hActor.h_tearDown()
      hActor = null

    it "should not started with an empty tag", (done) ->
      if hActor.inboundAdapters[0].started is false
        done()

    it "should update location, start and receive hTweet from France", (done) ->
      count = 0
      newProperties.locations = "-2.5,43.3,7.2,50.6"
      hActor.updateAdapter("twitter", newProperties)

      hActor.onMessage = (hMessage) =>
        count++
        hMessage.type.should.be.equal("hTweet")
        hMessage.payload.location[0].should.be.greaterThan(-2.5) and hMessage.payload.location[0].should.be.lessThan(7.2) and hMessage.payload.location[1].should.be.greaterThan(43.3) and hMessage.payload.location[1].should.be.lessThan(50.6)
        if count is 1
          done()

    it "should update tag, start and receive hTweet with apple tags", (done) ->
      count = 0
      newProperties.tags = "apple"
      newProperties.locations = ""
      hActor.updateAdapter("twitter", newProperties)

      hActor.onMessage = (hMessage) =>
        count++
        hMessage.type.should.be.equal("hTweet")
        hMessage.payload.text.should.match(/apple || Apple/)
        if count is 1
          done()

    it "should update adapter properties and receive hTweet with google tags", (done) ->
      count = 0
      newProperties.tags = "google"
      hActor.updateAdapter("twitter", newProperties)

      hActor.onMessage = (hMessage) =>
        count++
        hMessage.type.should.be.equal("hTweet")
        hMessage.payload.text.should.match(/google || Google/)
        if count is 1
          done()
