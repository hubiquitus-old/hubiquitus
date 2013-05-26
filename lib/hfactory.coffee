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
builtinSerializerNames = require("./hbuiltin").builtinSerializerNames

actors = {}
adapters = {}
serializers = {}


_with = (name, type, tab, clazz) ->
  if not type then throw new Error "#{name}'s type undefined"
  if not clazz then throw new Error "#{name} undefined"
  if tab[type]
    logger.warn "#{name} '#{type}' already defined"
  else
    logger.info "#{name} '#{type}' added"
    tab[type] = clazz

withActor = (type, actor) ->
  _with 'Actor', type, actors, actor


withAdapter = (type, adapter) ->
  _with 'Adapter', type, adapters, adapter

withSerializer = (type, serializer) ->
  _with 'Serializer', type, serializers, serializer

loadBuiltin  = (builtinNames,tab,type) ->  
  _.pairs(builtinNames).forEach (pair) ->
    name = pair[1]
    tab[name]=require "./#{type}/#{name}"



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

loadBuiltin builtinActorNames,actors,"actor"
loadBuiltin builtinAdapterNames,adapters,"adapters"
loadBuiltin builtinSerializerNames,serializers,"serializers"

loadCustom "#{process.cwd()}/actors", withActor
loadCustom "#{process.cwd()}/adapters", withAdapter
loadCustom "#{process.cwd()}/serializers", withSerializer

_new = (type, tab, properties) ->
  throw new Error "type undefined" if not type
  if not tab[type]
    tab[type] = require type
  else 
    if typeof tab[type] is "string"   
      tab[type] = require tab[type]
  new tab[type] properties

newActor = (type, properties) ->
  _new type, actors, properties

newAdapter = (type, properties) ->
  _new type, adapters, properties

newSerializer = (type, properties) ->
  _new type, serializers, properties



exports.newActor = newActor
exports.newAdapter = newAdapter
exports.newSerializer = newSerializer