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

hRelevantMessages = ->


  ###
  Method executed each time an hCommand with cmd = 'hRelevantMessages' is received.
  Once the execution finishes we should call the callback.
  @param hMessage - hMessage received with hCommand with cmd = 'hRelevantMessages'
  @param context - Actor's instance which call the command
  @param cb(status, result) - function that receives arg:
  status: //Constant from var status to indicate the result of the hCommand
  result: //Array of relevant hMessages
  ###
hRelevantMessages::exec = (hMessage, context, cb) ->
  @validateCmd hMessage, context, (err, result) ->
    unless err
      hMessages = []
      stream = context.dbInstance.collection(context.properties.collection).find(relevance:
        $gte: new Date().getTime()).sort(published: -1).skip(0).stream()
      stream.on "data", (localhMessage) ->
        localhMessage.msgid = localhMessage._id
        delete hMessage._id

        hMessages.push localhMessage  if hFilter.checkFilterValidity(localhMessage, hMessage.payload.filter, {actor:context.actor}).result

      stream.on "close", ->
        cb status.OK, hMessages


    else
      cb err, result


hRelevantMessages::validateCmd = (hMessage, context, cb) ->
  actor = hMessage.actor
  unless actor
    return cb(status.MISSING_ATTR, "missing actor")
  if context.properties.subscribers.indexOf(validator.getBareURN(hMessage.publisher)) < 0 and context.properties.subscribers.length > 0
    return cb(status.NOT_AUTHORIZED, "error recovering messages with current credentials")
  cb()

exports.Command = hRelevantMessages