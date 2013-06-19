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

describe "hChannel", ->
  hActor = undefined
  hChild = undefined
  hChildFilter = undefined
  status = require("../lib/codes").hResultStatus
  Channel = require "../lib/actors/hchannel"

  describe "publish", ->
    before () ->
      topology = {
        actor: "urn:localhost:channel",
        type: "hchannel",
        children: [
          {
            actor: "urn:localhost:actor",
            type: "hactor",
            method: "inproc"
            adapters: [ { type: "channel_in", channel: "urn:localhost:channel" , quickFilter: "unit"} ]
          }
        ],
        properties:
          subscribers:[],
          listenOn: "tcp://127.0.0.1",
          broadcastOn: "tcp://127.0.0.1",
          db:{
            host: "localhost",
            port: 27017,
            name: "test"
          },
          collection: "channel"

      }
      hActor = new Channel topology
      hActor.h_start()

    before () ->
      topology = {
        actor: "urn:localhost:actorFilter",
        type: "hactor",
        method: "inproc"
        adapters: [ { type: "channel_in", channel: "urn:localhost:channel" , quickFilter: "unit"} ]
      }
      hActor.createChild "hactor", "inproc", topology, (child) =>
        hChildFilter = child

    before () ->
      topology = {
        actor: "urn:localhost:actor",
        type: "hactor",
        method: "inproc"
        adapters: [ { type: "channel_in", channel: "urn:localhost:channel" } ]
      }
      hActor.createChild "hactor", "inproc", topology, (child) =>
        hChild = child

    after () ->
      hActor.h_tearDown()
      hActor = null
      hChild = null
      hChildFilter = null

    it "should publish message without quickFilter ", (done) ->
      @timeout(4000)
      msg = hActor.buildMessage("urn:localhost:channel", "string", "Hello #TΘ$Δ", {timeout:0})

      hChild.onMessage = (hMessage) ->
        hMessage.payload.should.be.equal("Hello #TΘ$Δ")
        done()
      msg.sent = new Date().getTime()
      hActor.h_onMessageInternal msg

    it "should publish message with quickFilter", (done) ->
      msg = hActor.buildMessage("urn:localhost:channel", "string", "Hello #TΘ$Δ", {timeout:0, headers:{h_quickFilter:"unit"}})

      hChildFilter.onMessage = (hMessage) ->
        hMessage.payload.should.be.equal("Hello #TΘ$Δ")
        done()

      hChild.onMessage = (hMessage) ->

      msg.sent = new Date().getTime()
      hActor.h_onMessageInternal msg


