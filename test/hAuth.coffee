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

describe "hAuth", ->
  hAuth = undefined
  config = require("./_config")
  hResultStatus = require("../lib/codes").hResultStatus
  Auth = require "../lib/actors/hauth"
  Session = require "../lib/actors/hsession"
  codes = require "../lib/codes"

  userUrn = config.logins[0].urn
  authUrn = config.logins[2].urn
  sessionUrn = config.logins[4].urn

  before () ->
    topology = {
      actor: authUrn,
      type: "hauth"
    }
    hAuth = new Auth topology

  after () ->
    hAuth.h_tearDown()
    hAuth = null

  it "should report NO_ERROR with a valid urn and login = password", (done) ->
    authMsg = hAuth.buildMessage authUrn, "hAuth", {login: userUrn, password: userUrn}
    authMsg.publisher = sessionUrn

    hAuth.send = (hMessage) ->
      hMessage.should.have.property "type", "hResult"
      hMessage.should.have.property "actor", sessionUrn
      hMessage.payload.should.have.property "status", hResultStatus.OK
      hMessage.payload.result.should.have.property "actor", userUrn
      hMessage.payload.result.should.have.property "errorCode", codes.errors.NO_ERROR
      done()

    hAuth.onMessage authMsg

  it "should report AUTH_FAILED with a login != password", (done) ->
    authMsg = hAuth.buildMessage authUrn, "hAuth", {login: userUrn, password: ""}
    authMsg.publisher = sessionUrn

    hAuth.send = (hMessage) ->
      hMessage.should.have.property "type", "hResult"
      hMessage.should.have.property "actor", sessionUrn
      hMessage.payload.should.have.property "status", hResultStatus.OK
      hMessage.payload.result.should.have.property "errorCode", codes.errors.AUTH_FAILED
      hMessage.payload.result.should.have.property "errorMsg", "invalid publisher or password"
      done()

    hAuth.onMessage authMsg

  it "should return a result with status MISSING_ATTR if auth message type isn't hAuth", (done) ->
    authMsg = hAuth.buildMessage authUrn, "invalid", {login: userUrn, password: ""}
    authMsg.publisher = sessionUrn

    hAuth.send = (hMessage) ->
      hMessage.should.have.property "type", "hResult"
      hMessage.should.have.property "actor", sessionUrn
      hMessage.payload.should.have.property "status", codes.hResultStatus.MISSING_ATTR
      hMessage.payload.should.have.property "result", "missing payload or payload is not of type hAuth"
      done()

    hAuth.onMessage authMsg

  it "should return a result with status MISSING_ATTR if no payload", (done) ->
    authMsg = hAuth.buildMessage authUrn, "hAuth"
    authMsg.publisher = sessionUrn

    hAuth.send = (hMessage) ->
      hMessage.should.have.property "type", "hResult"
      hMessage.should.have.property "actor", sessionUrn
      hMessage.payload.should.have.property "status", codes.hResultStatus.MISSING_ATTR
      hMessage.payload.should.have.property "result", "missing payload or payload is not of type hAuth"
      done()

    hAuth.onMessage authMsg

