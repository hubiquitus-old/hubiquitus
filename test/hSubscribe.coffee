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

describe "hSubscribe", ->
  cmd = undefined
  hActor = undefined
  hActor2 = undefined
  hChannel = undefined
  hChannel2 = undefined
  status = require("../lib/codes").hResultStatus
  Actor = require "../lib/actors/hactor"
  Tracker = require ("../lib/actors/htracker")
  existingCHID = "urn:localhost:#{config.getUUID()}"

  before () ->
    topology = {
      actor: config.logins[0].urn,
      type: "hactor"
    }
    hActor = new Actor topology

    properties =
      listenOn: "tcp://127.0.0.1:1221",
      broadcastOn: "tcp://127.0.0.1:2998",
      subscribers: [config.logins[0].urn],
      db:{
        host: "localhost",
        port: 27017,
        name: "test"
      },
      collection: existingCHID.replace(/[-.]/g, "")
    hActor.createChild "hchannel", "inproc", {actor: existingCHID, type : "hActor", properties: properties}, (child) =>
      hChannel = child

  after () ->
    hActor.h_tearDown()
    hActor = null

  it "should return hResult error MISSING_ATTR when actor is missing", (done) ->
    try
      hActor.subscribe undefined, "", (statuses, result) ->
    catch error
      should.exist error.message
      done()

  it "should return hResult error INVALID_ATTR with actor not a channel", (done) ->
    hActor.subscribe hActor.actor, "", (statuses, result) ->
      statuses.should.be.equal(status.NOT_AVAILABLE)
      result.should.match(/actor/)
      done()


  it "should return hResult error NOT_AUTHORIZED if not in subscribers list", (done) ->
    hChannel.properties.subscribers = [config.logins[2].urn]
    hActor.subscribe existingCHID, "", (statuses, result) ->
      statuses.should.be.equal(status.NOT_AUTHORIZED)
      result.should.be.a('string')
      hChannel.properties.subscribers = [config.logins[0].urn]
      done()


  it "should return hResult OK when correct", (done) ->
    hActor.subscribe existingCHID, "", (statuses, result) ->
      statuses.should.be.equal(status.OK)
      done()


  it "should return hResult error if already subscribed", (done) ->
    hActor.subscribe existingCHID, "", (statuses, result) ->
      statuses.should.be.equal(status.NOT_AUTHORIZED)
      result.should.be.a "string"
      done()

  it "should return hResult OK if correctly add a quickfilter", (done) ->
    find = false
    hActor.subscribe existingCHID, "quickfilter1", (statuses, result) ->
      statuses.should.be.equal(status.OK)
      result.should.be.equal("QuickFilter added")
      _.forEach hActor.inboundAdapters, (inbound) =>
        if inbound.channel is existingCHID
          for filter in inbound.listQuickFilter
            if filter is ""
              find = true
      unless find
        done()

  describe "from topology", ->
    before () ->
      topology = {
        actor: config.logins[2].urn,
        type: "hactor"
        adapters:[
          { type: "channel_in", channel:existingCHID }
        ]
      }
      hActor2 = new Actor topology
      hActor2.h_start()

      properties =
        listenOn: "tcp://127.0.0.1:2112",
        broadcastOn: "tcp://127.0.0.1:9289",
        subscribers: [config.logins[2].urn],
        db:{
          name: "test",
        }
        collection: existingCHID.replace(/[-.]/g, "")
      hActor2.createChild "hchannel", "inproc", {actor: existingCHID, type : "hActor", properties: properties}, (child) =>
        hChannel2 = child

    after () ->
      hActor2.h_tearDown()
      hActor2 = null

    it "should have channel in for existing channel", (done) ->
      hActor2.inboundAdapters.length.should.be.equal(0)
      setTimeout(=>
        hActor2.inboundAdapters.length.should.be.equal(1)
        done()
      , 600)

  describe "Channel Stop & Restart", ->
    hActor = undefined
    hChannel = undefined
    hTracker = undefined

    before () ->
      htrackerProps = {
        actor: "urn:localhost:tracker",
        type: "htracker",
        properties:{
          channel: {
            actor: "urn:localhost:trackChannel",
            type: "hchannel",
            properties: {
              listenOn: "tcp://127.0.0.1",
              broadcastOn: "tcp://127.0.0.1",
              subscribers: [],
              db:{
                host: "localhost",
                port: 27017,
                name: "admin"
              },
              collection: "trackChannel"
            }
          }
        },
        adapters: [ { type: "socket_in", url: "tcp://127.0.0.1:2997" } ]
      }

      hactorProps = {
        actor: config.logins[0].urn,
        type: "hactor",
        adapters: [
          {type: "socket_in", url: "tcp://127.0.0.1:2992" },
          {type: "channel_in", channel: "urn:localhost:channel"}
        ],
        trackers: [{
          trackerId: "urn:localhost:tracker",
          trackerUrl: "tcp://127.0.1:2997",
          trackerChannel: "urn:localhost:trackChannel"
          }]
      }

      hchannelProps = {
        actor: "urn:localhost:channel",
        type: "hchannel",
        properties: {
          subscribers: [],
          db:{
            host: "localhost",
            port: 27017,
            name: "admin"
            },
          collection: "channel"
        },
      trackers: [{
        trackerId: "urn:localhost:tracker",
        trackerUrl: "tcp://127.0.1:2997",
        trackerChannel: "urn:localhost:trackChannel"
        }]
      }

      hTracker = new Tracker htrackerProps
      hTracker.h_start()
      hTracker.createChild "hchannel", "inproc", hchannelProps, (child) =>
        hChannel = child
      hTracker.createChild "hactor", "inproc", hactorProps, (child) =>
        hActor = child

    after () ->
      hTracker.h_tearDown()

    it "Channel should be restarted correctly", (done) ->
      @timeout 3500
      setTimeout(=>
        hActor.subscriptions.should.include hChannel.actor
        hChannel.h_tearDown()
        setTimeout(=>
          hActor.subscriptions.length.should.equal 0
          hChannel.h_start()
          setTimeout(=>
            hActor.subscriptions.should.include hChannel.actor
            done()
          ,1000)
        ,1000)
      ,1000)
