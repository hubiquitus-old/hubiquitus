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

# TODO : more tests should be added. Currently only testing authentification

describe "socketio_connector", ->
  config = require("./_config")
  hResultStatus = require("../lib/codes").hResultStatus
  SocketIO_Connector = require("../lib/client_connector/socketio_connector")
  Actor = require "../lib/actor/hactor"
  codes = require "../lib/codes"

  hActor = undefined
  sock_conn = undefined
  authUrn = "urn:localhost:auth"
  actorUrn = config.logins[0].urn
  userUrn = config.logins[2].urn

  before () ->
    topology = {
      actor: actorUrn,
      type : "hActor",
      properties: {authActor: authUrn}
    }
    hActor = new Actor topology

    properties = {
      owner: hActor,
      port: 9999
    }

    sock_conn = new SocketIO_Connector(properties)

  after () ->
    hActor.h_tearDown()
    sock_conn = null
    hActor = null

  describe "authenticate", ->

    it "should report NO_ERROR with valid auth and a response with a valid urn", (done) ->
      data = {login: userUrn, password: userUrn}
      hActor.send = (hMessage, cb) ->
        if hMessage.actor is authUrn
          authResponse = hActor.buildResult actorUrn, hMessage.msgid, codes.hResultStatus.OK, {actor : data.login, errorCode : codes.errors.NO_ERROR, errorMsg: undefined}
          authResponse.publisher = authUrn
          cb authResponse

      sock_conn.authenticate data, (actor, errorCode, errorMsg) ->
        actor.should.be.equal data.login
        errorCode.should.be.equal codes.errors.NO_ERROR
        done()

    it "should report URN_MALFORMAT if auth actor response doesn't contain a valid urn", (done) ->
      data = {login: "invalid_urn", password: "invalid_urn"}
      hActor.send = (hMessage, cb) ->
        if hMessage.actor is authUrn
          authResponse = hActor.buildResult actorUrn, hMessage.msgid, codes.hResultStatus.OK, {actor : data.login, errorCode : codes.errors.NO_ERROR, errorMsg: undefined}
          authResponse.publisher = authUrn
          cb authResponse

      sock_conn.authenticate data, (actor, errorCode, errorMsg) ->
        should.not.exist actor
        errorCode.should.be.equal codes.errors.URN_MALFORMAT
        errorMsg.should.be.equal "urn malformat"
        done()

    it "should report TECH_ERROR if invalid response from auth actor", (done) ->
      data = {login: userUrn, password: userUrn}
      hActor.send = (hMessage, cb) ->
        if hMessage.actor is authUrn
          authResponse = hActor.buildResult actorUrn, hMessage.msgid, codes.hResultStatus.OK
          authResponse.publisher = authUrn
          cb authResponse

      sock_conn.authenticate data, (actor, errorCode, errorMsg) ->
        should.not.exist actor
        errorCode.should.be.equal codes.errors.TECH_ERROR
        errorMsg.should.be.equal "invalid response"
        done()

    it "should report auth error if auth actor responded with an error", (done) ->
      data = {login: userUrn, password: userUrn}
      errorCode = codes.errors.AUTH_FAILED
      errorMsg = "Invalid login"
      hActor.send = (hMessage, cb) ->
        if hMessage.actor is authUrn
          authResponse = hActor.buildResult actorUrn, hMessage.msgid, codes.hResultStatus.OK, {actor : data.login, errorCode : errorCode, errorMsg: errorMsg}
          authResponse.publisher = authUrn
          cb authResponse

      sock_conn.authenticate data, (actor, errorCode, errorMsg) ->
        should.not.exist actor
        errorCode.should.be.equal errorCode
        errorMsg.should.be.equal errorMsg
        done()