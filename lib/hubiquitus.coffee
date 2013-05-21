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
_ = require("underscore")

winston = require "winston"
logger = new winston.Logger
  transports: [
    new winston.transports.Console(colorize: true)
  ]


# Set ZMQ_MAX_SOCKETS to the highest possible value because hubiquitus uses a lot of sockets.
if not process.env.ZMQ_MAX_SOCKETS or process.env.ZMQ_MAX_SOCKETS <= 0
  process.env.ZMQ_MAX_SOCKETS = 1000000

factory = require "./hfactory"


to_exports = {}

# Helper for accessing to Hubiquitus built-in classes in developer code.
builtinActorNames = require("./hbuiltin").builtinActorNames
_.pairs(builtinActorNames).forEach (pair) ->
  to_exports[pair[0]] = require "./actor/#{pair[1]}"

builtinAdapterNames = require("./hbuiltin").builtinAdapterNames
_.pairs(builtinAdapterNames).forEach (pair) ->
  to_exports[pair[0]] = require "./adapters/#{pair[1]}"

validator = require "./validator"
to_exports.validator = validator

filter = require "./hFilter"
to_exports.filter = filter

codes = require "./codes"
to_exports.codes = codes

# Start an engine based on a topoplogy.
# topology can be :
# - undefined   =>  require "current_path/topology"
# - a string    =>  require "current_path/string" 
# - an object   =>  the object is the topology
to_exports.start = (topology) ->
  unless typeof topology is "object"
    topology = require "#{process.cwd()}/#{topology or "topology"}"

  logger.info "Hubiquitus is starting ...."
  setTimeout ()->
    engine = factory.newActor topology.type, topology
    engine.on "hStatus", (status) ->
      return unless status is "started"
      process.on "SIGINT", ->
        engine.h_tearDown()
        process.exit()
    engine.h_start()
    logger.info "Hubiquitus started"
  ,1000

# Exports
module.exports = to_exports;
