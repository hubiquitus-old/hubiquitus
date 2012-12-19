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
log = require("winston")
status = require("../codes").hResultStatus
validators = require("../validator")
_ = require "underscore"


hSubscribe = ->


  ###
  Subscribes a publisher to a channel
  @param hMessage - hMessage with hCommand received with cmd = 'hSubscribe'
  @param context - Auxiliary functions,attrs from the controller.
  @param cb(status, result) - function that receives args:
  status: //Constant from var status to indicate the result of the hCommand
  result: undefined if ok.
  ###
hSubscribe::exec = (hMessage, context, cb) ->
  statusValue = null
  result = null
  actor = hMessage.actor
  unless actor
    return cb(status.MISSING_ATTR, "missing actor")
  unless validators.isChannel(actor)
    return cb(status.INVALID_ATTR, "actor is not a channel")

  #Convert sender to bare jid
  jid = hMessage.publisher.replace(/\/.*/, "")
  if context.properties.active is false
    statusValue = status.NOT_AUTHORIZED
    result = "the channel is inactive"

    #Check if in subscribers list
  else if context.properties.subscribers.indexOf(jid) < 0 and context.properties.subscribers.length > 0
    statusValue = status.NOT_AUTHORIZED
    result = "not allowed to subscribe to \"" + actor + "\""

  else
    statusValue = status.OK
    _.forEach context.outboundAdapters, (outbound) =>
      if outbound.targetActorAid is context.subscribersAlias
        result = outbound.url

  cb statusValue, result

exports.Command = hSubscribe