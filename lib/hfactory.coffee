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


_with = (name, type, array, clazz) ->
  if not type then throw new Error "#{name}'s type undefined"
  if not clazz then throw new Error "#{name} undefined"
  if array[type]
    logger.warn "#{name} '#{type}' already defined"
  else
    logger.info "#{name} '#{type}' added"
    array[type] = clazz

withActor = (type, actor) ->
  _with 'Actor', type, actors, actor


withAdapter = (type, adapter) ->
  _with 'Adapter', type, adapters, adapter

withSerializer = (type, serializer) ->
  _with 'Serializer', type, serializers, serializer

loadBuiltin  = (builtinNames,array,type) ->  
  _.pairs(builtinNames).forEach (pair) ->
    name = pair[1]
    array[name]=require "./#{type}/#{name}"

loadCustom = (pathToLoad,fn) ->
  results = walkSync pathToLoad
  _(results).each (file) ->
    ext = path.extname(file)
    return if ext isnt ".coffee"

    # Built the relative name 
    # actors/tools/myActor.coffe 
    # => type : tools/myActor
    relative = path.relative(pathToLoad,file)
    type = relative.match(/(.+)\.coffee$/)[1]
    fn type,file 

walkSync = (dir) ->
  logger.info "Loading #{dir}"
  results = []
  try
    list = fs.readdirSync dir
  catch error
    logger.info "#{dir} doesn't exist"
  _(list).each (file) ->
    file = dir + '/' + file
    stat = fs.statSync(file)
    if (stat and stat.isDirectory())
      results=results.concat(walkSync(file))
    else
      results.push(file)
  return results


loadBuiltin builtinActorNames,actors,"actor"
loadBuiltin builtinAdapterNames,adapters,"adapters"
loadBuiltin builtinSerializerNames,serializers,"serializers"

loadCustom "#{process.cwd()}/actors", withActor
loadCustom "#{process.cwd()}/adapters", withAdapter
loadCustom "#{process.cwd()}/serializers", withSerializer

_new = (type, array, properties) ->
  throw new Error "type undefined" if not type
  if not array[type]
    # can require a type into external module
    array[type] = require type
  else 
    if typeof array[type] is "string"   
      array[type] = require array[type]
  new array[type] properties

newActor = (type, properties) ->
  _new type, actors, properties

newAdapter = (type, properties) ->
  _new type, adapters, properties

newSerializer = (type, properties) ->
  _new type, serializers, properties



exports.newActor = newActor
exports.newAdapter = newAdapter
exports.newSerializer = newSerializer
