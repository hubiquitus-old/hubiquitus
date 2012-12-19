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
#unsubscriberModule = require("./hUnsubscribe.js").Command
validators = require("../validator")
hFilter = require("../hFilter")
dbPool = require("../dbPool").getDbPool()

hCreateUpdateChannel = ->


###
Method executed each time an hCommand with cmd = 'hCreateUpdateChannel' is received.
Once the execution finishes cb is called.
@param hCommand - hCommand received with cmd = 'hCreateUpdateChannel'
@param context - Auxiliary functions,attrs from the controller.
@param cb(status, result) - function that receives args:
status: //Constant from var status to indicate the result of the hCommand
result: //An optional result object defined by the hCommand
###
hCreateUpdateChannel::exec = (hMessage, context, cb) ->
  hCommand = hMessage.payload
  channel = hCommand.params

  if not channel or typeof channel isnt "object"
    return cb status.INVALID_ATTR, "invalid params object received"

  #Test owner against publisher (ignore resources)
  if channel.owner and not validators.compareJIDs(hMessage.publisher, channel.owner)
    return cb status.NOT_AUTHORIZED, "owner does not match sender"
  if channel.actor is `undefined`
    return cb status.MISSING_ATTR, "Missing actor in params"
  if channel.actor is "" or typeof channel.actor isnt "string"
    return cb status.INVALID_ATTR, "actor must be a string"

  channel.filter = channel.filter or {}
  checkFormat = hFilter.checkFilterFormat(channel.filter)
  if checkFormat.result is false
    return cb status.INVALID_ATTR, checkFormat.error

  ###If subscribers were removed, unsubscribe them
  unsubscriber = new unsubscriberModule()

  #copy message for unsubscribe
  unsubscribeMsg = {}
  Object.getOwnPropertyNames(hMessage).forEach (name) ->
    unsubscribeMsg[name] = hMessage[name]

  unsubscribeMsg.type = "hCommand"
  unsubscribeMsg.payload = {}
  if existingChannel
    i = 0

    while i < existingChannel.subscribers.length
      if channel["subscribers"].indexOf(existingChannel.subscribers[i]) < 0
        unsubscribeMsg.publisher = existingChannel.subscribers[i]
        unsubscribeMsg.payload.params = actor: channel.actor
        unsubscriber.exec unsubscribeMsg, context, (status, result) ->
    i++
  ###

  #Set received channel as our _id
  channel._id = channel.actor
  delete channel.actor

  #Remove empty headers and location
  validators.cleanEmptyAttrs channel, ["headers", "location", "chdesc"]

  validators.validateHChannel channel, (statusCode, result) =>
    if statusCode is status.OK
      channel.actor = channel._id
      delete channel._id

      channel.listenOn = "tcp://127.0.0.1:#{Math.floor(Math.random() * 98)+4000}"
      channel.broadcastOn = inboundAdapters = "tcp://127.0.0.1:#{Math.floor(Math.random() * 98)+4000}"
      topology =
        actor: channel.actor
        properties: channel

      log.debug "Create Child : ",channel.actor
      context.createChild "hchannel", "inproc", topology
      cb status.OK
    else
      cb statusCode, result

exports.Command = hCreateUpdateChannel
