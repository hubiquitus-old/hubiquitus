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
status = require("../codes").hResultStatus
validator = require("../validator")
hFilter = require("../hFilter")
hGetThread = ->


  ###
  Method executed each time an hCommand with cmd = 'hGetThread' is received.
  Once the execution finishes we should call the callback.
  @param hMessage - hMessage received with hCommand with cmd = 'hGetThread'
  @param context - Actor's instance which call the command
  @param cb(status, result) - function that receives arg:
  status: //Constant from var status to indicate the result of the hCommand
  result: //An [] of hMessages
  ###
hGetThread::exec = (hMessage, context, cb) ->
  @checkValidity hMessage, context, (err, result) ->
    unless err
      hCommand = hMessage.payload
      hMessages = []
      actor = hMessage.actor
      convid = hCommand.params.convid
      sort = hCommand.params.sort or 1
      sort = 1  if hCommand.params.sort isnt -1 and hCommand.params.sort isnt 1

      stream = context.dbInstance.collection(context.properties.collection).find(convid: convid).sort(published: sort).skip(0).stream()
      firstElement = true
      stream.on "data", (localhMessage) ->
        localhMessage.actor = actor
        localhMessage.msgid = localhMessage._id
        delete localhMessage._id

        if firstElement and hFilter.checkFilterValidity(localhMessage, hCommand.filter, {actor:context.actor}).result is false
          stream.destroy()
        firstElement = false
        hMessages.push localhMessage

      stream.on "close", ->
        cb status.OK, hMessages


    else
      cb err, result


hGetThread::checkValidity = (hMessage, context, cb) ->
  hCommand = hMessage.payload
  if not hCommand.params or (hCommand.params not instanceof Object)
    return cb(status.INVALID_ATTR, "invalid params object received")
  actor = hMessage.actor
  convid = hCommand.params.convid
  unless actor
    return cb(status.MISSING_ATTR, "missing actor")
  unless convid
    return cb(status.MISSING_ATTR, "missing convid")
  unless typeof convid is "string"
    return cb(status.INVALID_ATTR, "convid is not a string")
  if context.properties.subscribers.indexOf(validator.getBareURN(hMessage.publisher)) < 0 and context.properties.subscribers.length > 0
    return cb(status.NOT_AUTHORIZED, "the sender is not in the channel subscribers list")
  cb()

exports.Command = hGetThread