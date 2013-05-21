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

_ = require "underscore"
# Factory : 
# load all dependencies
fs = require "fs"
path = require "path" 
winston = require "winston"
logger = new winston.Logger
  transports: [
    new winston.transports.Console(colorize: true)
  ]

builtinActorNames = require("./hbuiltin").builtinActorNames
builtinAdapterNames = require("./hbuiltin").builtinAdapterNames

actors = {}
adapters = {}


withActor = (type, actor) ->
  throw new Error "Actor's type undefined" if not type 
  throw new Error "Actor undefined" if not actor
  if actors[type]
    logger.warn "Actor '#{type}' already defined"
  else
    logger.info "Actor '#{type}' added"
    actors[type] = actor


withAdapter = (type, adapter) ->
  throw new Error "Adapter's type undefined" if not type
  throw new Error "Adapter undefined" if not adapter
  if adapters[type]
    logger.warn "Adapter '#{type}' already defined"
  else
    logger.info "Adapter '#{type}' added"
    adapters[type] = adapter

loadBuiltinActors = ->
  _.pairs(builtinActorNames).forEach (pair) ->
    name = pair[1]
    actors[name]=require "./actor/#{name}"

loadBuiltinAdapters = ->  
  _.pairs(builtinAdapterNames).forEach (pair) ->
    name = pair[1]
    adapters[name]=require "./adapters/#{name}"

loadCustom = (pathToLoad,fn) ->
  walk pathToLoad, (err,results) ->
    throw err if err
    _(results).each (file) ->
      ext = path.extname(file)
      if ext is ".js" or ext is ".node" or ext is ".json"
        # TODO : Error or Warning 
        logger.warn "File #{file} will override the .coffee version" 
      return if path.extname(file) isnt ".coffee"
      fn path.basename(file,".coffee"),file 

walk = (dir, done) -> 
  logger.info "Loading #{dir}"
  results = [];
  fs.readdir dir, (err, list) ->
    return done(err) if err
    i = 0;
    next = () ->
      file = list[i++];
      return done(null, results) if not file
      file = dir + '/' + file;
      fs.stat file, (err, stat) ->
        if (stat and stat.isDirectory())
          walk file, (err, res) ->
            results = results.concat(res);
            next();
        else
          results.push(file);
          next();
    next()

loadBuiltinActors()
loadBuiltinAdapters()

loadCustom "#{process.cwd()}/actors", withActor
loadCustom "#{process.cwd()}/adapters", withAdapter

newActor = (type, properties) ->
  # Controls and warning about builtinAdapters override
  throw new Error "Actor's type undefined" if not type
  if not actors[type]
    actors[type] = require type
  else if typeof actors[type] is "string" 
    actors[type] = require actors[type]
  new actors[type] properties

newAdapter = (type, properties) ->
  # Controls and warning about builtinAdapters override
  throw new Error "Adapter's type undefined" if not type
  if not adapters[type]
    adapters[type] = require type
  else if typeof adapters[type] is "string" 
    adapters[type] = require adapters[type]
  new adapters[type] properties

exports.newActor = newActor
exports.newAdapter = newAdapter


