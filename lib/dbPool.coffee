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

{EventEmitter} = require "events"
mongo = require("./mongo.coffee").db
log = require("winston")
opts = require("./options.coffee")
codes = require("./codes.coffee")
validators = require("./validator.coffee")

#Events
util = require("util")
events = require("events").EventEmitter
dbInstances = {}

class DbPool extends EventEmitter
  constructor: () ->
    log.remove(log.transports.Console)
    log.add(log.transports.Console, {level: "INFO"})
    log.debug "dbPool started"
    events.call this

  getDb: (dbProperties, cb) ->
    dbName = dbProperties.name.replace(/\./g, "_")
    dbInstance = dbInstances[dbName]
    if dbInstance
      if cb
        if dbInstance.status is 1
          cb dbInstance
        else
          if dbInstance.queue
            dbInstance.queue.push cb
          else
            dbInstance.queue = []
            dbInstance.queue.push cb
      else
        dbInstance
    else
      newInstance = new mongo()
      dbInstances[dbName] = newInstance

      #Parse URI
      host = dbProperties.host or "localhost"
      port = dbProperties.port or 27017
      uri = "mongodb://" + host + ":" + port + "/" + dbName
      newInstance.on "error", (err) ->
        log.error "Error Connecting to database", err
        process.exit 1


      #Start connection to Mongo
      newInstance.connect uri, (db) ->
        if cb
          cb db
        if newInstance.queue
          while newInstance.queue.length > 0
            cb = newInstance.queue.pop()
            cb db

      newInstance  unless cb


dbPoolSingleton = undefined
exports.getDbPool = () ->
  unless dbPoolSingleton
    dbPoolSingleton = new DbPool
  dbPoolSingleton


