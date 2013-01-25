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

###
Recovers last published messages to a channel. The messages recovered will
only be returned if they were persistent.
Receives as parameter an actor, an optional quantity of messages to recover,
if this quantity is not specified the default value from the channel will be
tried and if not the default value of the command.
###
status = require("../codes").hResultStatus
validator = require("../validator")
hFilter = require("../hFilter")
dbPool = require("../dbPool").getDbPool()

hGetLastMessages = ->

  #Default max quantity of messages to be returned. This will be used
  #If a max quantity is not specified and if there is not a default value for the channel
  @quant = 10


###
Method executed each time an hCommand with cmd = 'hGetLastMessages' is received.
Once the execution finishes we should call the callback.
@param hMessage - hMessage received with cmd = 'hGetLastMessages'
@param context - Models from the database to store/search data. See lib/mongo.js
@param cb(status, result) - function that receives arg:
status: //Constant from var status to indicate the result of the hCommand
result: [hMessage]
###
hGetLastMessages::exec = (hMessage, context, cb) ->
  hCommand = hMessage.payload
  params = hCommand.params
  actor = hMessage.actor

  #Test for missing actor
  unless actor
    return cb(status.MISSING_ATTR, "command missing actor")
  sender = hMessage.publisher.replace(/\/.*/, "")
  quant = @quant
  console.log context.properties.subscribers
  if context.properties.subscribers.indexOf(sender) > -1 or context.properties.subscribers.length is 0
    if params
      quant = params.nbLastMsg or quant
    else
      quant = quant

    #Test if quant field by the user is a number
    quant = parseInt(quant)
    quant = (if isNaN(quant) then @quant else quant)

    hMessages = []
    dbPool.getDb context.properties.db.dbName, (dbInstance) ->
      stream = dbInstance.get(context.properties.db.dbCollection).find({}).sort(published: -1).skip(0).stream()
      stream.on "data", (localhMessage) ->
        hMessages.actor = localhMessage._id
        delete localhMessage._id

        if localhMessage and hFilter.checkFilterValidity(localhMessage, hCommand.filter, {actor:context.actor}).result
          hMessages.push localhMessage
          stream.destroy()  if --quant is 0

      stream.on "close", ->
        cb status.OK, hMessages
  else
    cb status.NOT_AUTHORIZED, "not authorized to retrieve messages from \"" + actor

exports.Command = hGetLastMessages