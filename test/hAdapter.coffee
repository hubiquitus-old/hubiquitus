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
url = require "url"
factory = require "../lib/hfactory"

describe "hAdapter", ->
  hActor = undefined
  hActor2 = undefined
  hResultStatus = require("../lib/codes").hResultStatus
  Actor = require "../lib/actors/hactor"
  Channel = require "../lib/actors/hchannel"

  describe "socket_in collision", ->
    http = require "http"

    before () ->
      topology = {
        actor: config.logins[1].urn,
        type: "hactor",
        properties: {},
        adapters: [ { type: "socket_in", url: "tcp://127.0.0.1:2112" } ]
      }
      hActor = new Actor topology
      hMessage = hActor.h_buildSignal(hActor.actor, "start", {})
      hMessage.sent = new Date().getTime()
      hActor.h_onMessageInternal(hMessage)

      topology = {
        actor: config.logins[3].urn,
        type: "hactor",
        properties: {},
        adapters: [ { type: "socket_in", url: "tcp://127.0.0.1:2112" } ]
      }
      hActor2 = new Actor(topology)
      hMessage2 = hActor2.h_buildSignal(hActor2.actor, "start", {})
      hMessage2.sent = new Date().getTime()
      hActor2.h_onMessageInternal(hMessage2)

    after () ->
      hActor.h_tearDown()
      hActor = null
      hActor2.h_tearDown()
      hActor2 = null

    it "should avoid port collision", (done) ->
      port_hActor = url.parse(hActor.inboundAdapters[0].url)
      port_hActor2 = url.parse(hActor2.inboundAdapters[0].url)
      port_hActor2.should.not.be.equal(port_hActor)
      done()

  describe "channel_out collision", ->
    http = require "http"

    before () ->
      topology = {
        actor: config.logins[1].urn,
        type: "hchannel",
        properties: {
          subscribers:[config.logins[1].urn, config.logins[2].urn],
          listenOn: "tcp://127.0.0.1:1221",
          broadcastOn: "tcp://127.0.0.1:2998",
          db:{
            host: "localhost",
            port: 27017,
            name: "test"
          },
          collection: (config.logins[1].urn).replace(/[-.]/g, "")
        }
      }
      hActor = new Channel topology
      hMessage = hActor.h_buildSignal(hActor.actor, "start", {})
      hMessage.sent = new Date().getTime()
      hActor.h_onMessageInternal(hMessage)

      topology = {
        actor: config.logins[3].urn,
        type: "hchannel",
        properties: {
          subscribers:[config.logins[1].urn, config.logins[2].urn],
          listenOn: "tcp://127.0.0.1:2112",
          broadcastOn: "tcp://127.0.0.1:2998",
          db:{
            host: "localhost",
            port: 27017,
            name: "test"
          },
          collection: (config.logins[3].urn).replace(/[-.]/g, "")
        }
      }
      hActor2 = new Channel topology
      hMessage2 = hActor2.h_buildSignal(hActor2.actor, "start", {})
      hMessage2.sent = new Date().getTime()
      hActor2.h_onMessageInternal(hMessage2)

    after () ->
      hActor.h_tearDown()
      hActor = null
      hActor2.h_tearDown()
      hActor2 = null

    it "should avoid port collision", (done) ->
      port_hActor = url.parse(hActor.outboundAdapters[0].url)
      port_hActor2 = url.parse(hActor2.outboundAdapters[0].url)
      port_hActor2.should.not.be.equal(port_hActor)
      done()