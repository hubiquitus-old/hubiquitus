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
This command can be executed using two different algorithms:
1. A 'linear' algorithm that is mono thread and a little faster if executed in a single environment without shards
2. A 'mapReduce' algorithm that SHOULD be faster in a sharded environment.

The default implementation is linear. to change set this.implementation to 'mapReduce' in hGetThreads constructor.
###
hResultStatus = require("../codes").hResultStatus
validator = require("../validator")
dbPool = require("../dbPool").getDbPool()
hFilter = require("../hFilter")
hGetThreads = ->
  @implementation = "linear"


###
Method executed each time an hCommand with cmd = 'hGetThreads' is received.
Once the execution finishes we should call the callback.
@param hMessage - hMessage received with hCommand with cmd = 'hGetThreads'
@param context - Auxiliary functions,attrs from the controller.
@param cb(status, result) - function that receives arg:
status: //Constant from var status to indicate the result of the hCommand
result: //An [] of hMessages
###
hGetThreads::exec = (hMessage, context, cb) ->
  self = this
  @checkValidity hMessage, context, (err, result) ->
    unless err
      self[self.implementation](hMessage, context, cb);
    else
      cb err, result


hGetThreads::mapReduce = (hMessage, context, cb) ->
  hCommand = hMessage.payload
  status = hCommand.params.status
  actor = hMessage.actor
  self = this
  map = ->
    emit @convid,
      status: @payload.status
      published: @published


  reduce = (k, values) ->
    chosenValue = values[0]
    values.forEach (value) ->
      chosenValue = value  if chosenValue.published < value.published

    chosenValue

  dbPool.getDb context.properties.db.dbName, (dbInstance) ->
    dbInstance.get(context.properties.db.dbCollection).mapReduce map, reduce, {out:replace: UUID.generate()}, (err, collection) ->
      unless err
        convids = []
        stream = collection.find({}).stream()
        stream.on "data", (elem) ->
          convids.push elem._id  if elem.value.status is status and hFilter.checkFilterValidity(elem, hCommand.filter, {actor:context.actor}).result

        stream.on "close", ->
          collection.drop()
          self.filterMessages actor, convids, context, hCommand.filter, cb

      else
        cb hResultStatus.TECH_ERROR, JSON.stringify(err)



hGetThreads::linear = (hMessage, context, cb) ->
  hCommand = hMessage.payload
  status = hCommand.params.status
  actor = hMessage.actor
  self = this
  dbPool.getDb context.properties.db.dbName, (dbInstance) ->
    stream = dbInstance.get(context.properties.db.dbCollection).find(type: /hConvState/i).streamRecords()
    foundElements = {}
    stream.on "data", (hMessage) ->
      if foundElements[hMessage.convid]
        foundElements[hMessage.convid] = hMessage  if foundElements[hMessage.convid].published < hMessage.published
      else
        foundElements[hMessage.convid] = hMessage

    stream.on "end", ->
      convids = []
      for convid of foundElements
        convids.push convid  if foundElements[convid].payload.status is status
      self.filterMessages actor, convids, context, hCommand.filter, cb


hGetThreads::filterMessages = (actor, convids, context, filter, cb) ->
  filteredConvids = []
  regexConvids = "("

  #If no convids or no filters for the channel, do not access the db
  return cb(hResultStatus.OK, convids)  if convids.length is 0
  i = 0

  while i < convids.length
    regexConvids += convids[i] + "|"
    i++
  regexConvids = regexConvids.slice(0, regexConvids.length - 1) + ")"
  dbPool.getDb context.properties.db.dbName, (dbInstance) ->
    stream = dbInstance.get(context.properties.db.dbCollection).find(
      convid: new RegExp(regexConvids)
      type:
        $ne: "hConvState"
    ).stream()
    convidDone = false
    stream.on "data", (hMessage) ->
      if hFilter.checkFilterValidity(hMessage, filter, {actor:context.actor}).result
        if filteredConvids.length is 0
          filteredConvids.push hMessage.convid
        else
          convidDone = false
          i = 0
          while i < filteredConvids.length
            convidDone = true  if filteredConvids[i] is hMessage.convid
            i++
          filteredConvids.push hMessage.convid  if convidDone is false

    stream.on "close", ->
      cb hResultStatus.OK, filteredConvids


hGetThreads::checkValidity = (hMessage, context, cb) ->
  hCommand = hMessage.payload
  if not hCommand.params or (hCommand.params not instanceof Object)
    return cb(hResultStatus.INVALID_ATTR, "invalid params object received")
  actor = hMessage.actor
  status = hCommand.params.status
  unless actor
    return cb(hResultStatus.MISSING_ATTR, "missing actor")
  unless status
    return cb(hResultStatus.MISSING_ATTR, "missing status")
  unless typeof status is "string"
    return cb(hResultStatus.INVALID_ATTR, "status is not a string")
  if context.properties.subscribers.indexOf(validator.getBareURN(hMessage.publisher)) < 0 and context.properties.subscribers.length > 0
    return cb(hResultStatus.NOT_AUTHORIZED, "the sender is not in the channel subscribers list")
  cb()


UUID = ->
UUID.generate = ->
  a = UUID._gri
  b = UUID._ha
  b(a(32), 8) + "-" + b(a(16), 4) + "-" + b(16384 | a(12), 4) + "-" + b(32768 | a(14), 4) + "-" + b(a(48), 12)

UUID._gri = (a) ->
  (if 0 > a then NaN else (if 30 >= a then 0 | Math.random() * (1 << a) else (if 53 >= a then (0 | 1073741824 * Math.random()) + 1073741824 * (0 | Math.random() * (1 << a - 30)) else NaN)))

UUID._ha = (a, b) ->
  c = a.toString(16)
  d = b - c.length
  e = "0"

  while 0 < d
    d & 1 and (c = e + c)
    d >>>= 1
    e += e
  c

exports.Command = hGetThreads