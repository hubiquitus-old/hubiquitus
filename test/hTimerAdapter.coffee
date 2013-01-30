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

describe "hTimerAdapter", ->
  hActor = undefined
  config = require("./_config")
  hResultStatus = require("../lib/codes").hResultStatus
  actorModule = require("../lib/actor/hactor")

  describe "millisecond", ->
    before () ->
      topology = {
        actor: "urn:localhost:actor",
        type: "hactor",
        properties: {},
        adapters: [ { type: "timerAdapter", properties: {alert:"timer_milli", mode: "millisecond", period:100}} ]
      }
      hActor = actorModule.newActor(topology)
      hActor.h_onMessageInternal(hActor.buildSignal(hActor.actor, "start", {}))

    after () ->
      hActor.h_tearDown()
      hActor = null

    it "should receive 5 message in 500ms", (done) ->
      incoming_msg = 0
      hActor.onMessage = (hMessage) =>
        hMessage.payload.alert.should.be.equal("timer_milli")
        incoming_msg++

      setTimeout(=>
        incoming_msg.should.be.equal(5)
        done()
      , 510)

  describe "crontab", ->
    before () ->
      topology = {
        actor: "urn:localhost:actor",
        type: "hactor",
        properties: {},
        adapters: [ { type: "timerAdapter", properties: {alert:"timer_cron", mode: "crontab", crontab:"* * * * * *"}} ]
      }
      hActor = actorModule.newActor(topology)
      hActor.h_onMessageInternal(hActor.buildSignal(hActor.actor, "start", {}))

    after () ->
      hActor.h_tearDown()
      hActor = null

    it "should receive 2 message in 2sec", (done) ->
      @timeout(3000)
      incoming_msg = 0
      hActor.onMessage = (hMessage) =>
        hMessage.payload.alert.should.be.equal("timer_cron")
        incoming_msg++

      setTimeout(=>
        incoming_msg.should.be.equal(2)
        done()
      , 2100)

