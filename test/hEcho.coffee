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

describe "hEcho", ->
  echoCmd = undefined
  hActor = undefined
  status = require("../lib/codes").hResultStatus
  actorModule = require("../lib/actor/hsession")

  before () ->
    topology = {
      actor: config.logins[0].urn,
      type: "hsession"
    }
    hActor = actorModule.newActor(topology)

  after () ->
    hActor.h_tearDown()
    hActor = null

  beforeEach (done) ->
    echoCmd = config.makeHMessage("session", hActor.actor, "hCommand", {})
    echoCmd.payload =
      cmd: "hEcho"
      params:
        hello: "world"
    done()

  it "should return hResult error if the hMessage can not be treat", (done) ->
    echoCmd.payload.params.error = "DIV0"
    hActor.send = (hMessage) ->
      hMessage.should.have.property "ref", echoCmd.msgid
      hMessage.payload.should.have.property "status", status.TECH_ERROR
      done()

    hActor.h_onMessageInternal echoCmd


  describe "#Execute hEcho", ->
    it "should emit result echoing input", (done) ->
      hActor.send = (hMessage) ->
        should.exist hMessage.payload.status
        should.exist hMessage.payload.result
        hMessage.payload.status.should.be.equal status.OK
        hMessage.payload.result.should.be.equal echoCmd.payload.params
        done()

      hActor.h_onMessageInternal echoCmd

