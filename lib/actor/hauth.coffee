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

{Actor} = require "./hactor"
zmq = require "zmq"
_ = require "underscore"
statuses = require("../codes").statuses
errors = require("../codes").errors
validator = require "../validator"
codes = require "../codes"


class Auth extends Actor

  constructor: (properties) ->
    super
    @type = 'auth'

  onMessage: (hMessage) ->
    if not hMessage or not hMessage.payload or hMessage.type isnt "hAuth"
      if hMessage
        authResponse = @buildResult hMessage.publisher, hMessage.msgid, codes.hResultStatus.MISSING_ATTR, "missing payload or payload is not of type hAuth"
        @send authResponse
      return
    @auth hMessage.payload.login, hMessage.payload.password, hMessage.payload.context, (actor, errorCode, errorMsg) =>
      authResponse = @buildResult hMessage.publisher, hMessage.msgid, codes.hResultStatus.OK, {actor : actor, errorCode : errorCode, errorMsg: errorMsg}
      @send authResponse

  # Should be overrided to implement own auth system.
  # context : extra data
  # cb
  #   actor : urn of user. null if auth_failed
  #   errorCode : authentification status. If ok it should be NO_ERROR
  #   errorMsg : if ok, it should be user urn, else if should be error message
  auth: (login, password, context, cb) ->
    if(login is password)
      @log "debug", "Login successful for user #{login}"
      cb login, codes.errors.NO_ERROR
    else
      @log "debug", "Invalid login for user #{login}"
      cb undefined, codes.errors.AUTH_FAILED, "invalid publisher or password"


exports.Auth = Auth
exports.newActor = (properties) ->
  new Auth(properties)