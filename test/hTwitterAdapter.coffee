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
            consumerKey: "cMXVWvotA5c86Nc8tPhtvA",
            consumerSecret: "VklYGUWU31Qh8ZnhAX1rt82nTkmfvey3U6rbuBxnAk",
            twitterAccesToken: "819820982-H4lPh9e0EvsivXdfaORl1lJSdzPdCpQYfHAqclsP",
            twitterAccesTokenSecret: "Zex6O4tEgEPIF2cE39XVcg0C5MJNxJfV7FNRqSupu0c",
            tags:""
          }
        } ]
      }
      hActor = new Actor topology
      msg = hActor.h_buildSignal(hActor.actor, "start", {})
      msg.sent = new Date().getTime()
      hActor.h_onMessageInternal(msg)

    after () ->
      hActor.h_tearDown()
      hActor = null

    it "should not started with an empty tag", (done) ->
      if hActor.inboundAdapters[0].started is false
        done()

    it "should update tag, start and receive hTweet with apple tags", (done) ->
      count = 0
      newProperties.tags = "apple"
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
