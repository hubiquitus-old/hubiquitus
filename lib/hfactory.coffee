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


# Factory : 
# load all dependencies
fs = require "fs"
winston = require "winston"
logger = new winston.Logger
  transports: [
    new winston.transports.Console(colorize: true)
  ]

builtinActorsName = ['hactor','hauth','hchannel','hdispatcher','hgateway',
                     'hsession','htracker']
builtinAdaptersName = ['channel_in','channel_out','fork','http_in',
                       'http_out','inproc','lb_socket_in','lb_socket_out',
                       'socket_in','socket_out','socketIO','timerAdapter',
                       'twitter_in']

actors = {}
adapters = {}


withActor = (type, actor) ->
  if not type then throw new Error "Actor's type undefined"
  if not actor then throw new Error "Actor undefined"
  if actors[type]
    logger.warn "Actor '#{type}' already defined"
  else
    logger.info "Actor '#{type}' added"
    actors[type] = actor

withAdapter = (type, adapter) ->
  if not type then throw new Error "Adapter's type undefined"
  if not adapter then throw new Error "Adapter undefined"
  if adapters[type]
    logger.warn "Adapter '#{type}' already defined"
  else
    logger.info "Adapter '#{type}' added"
    adapters[type] = adapter


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


loadDirectory = (path, callback) ->
  return unless fs.existsSync path
  stats =  fs.statSync path
  return unless stats.isDirectory()
  logger.info "Scanning #{path}..."
  files = fs.readdirSync path
  files.forEach (file) ->
    # TODO Recursive file loading 
    if (file.indexOf ".coffee" isnt -1) and (fs.statSync("#{path}/#{file}").isFile())
      callback file.substr(0, pos), "#{path}/#{file}"  

loadActors = () ->
  builtinActorsName.forEach(name) -> 
    require "./actor/#{name}"
  loadDirectory "#{process.cwd()}/actors", withActor  

loadAdapters = () -> 
  builtinAdaptersName.forEach(name) -> 
    require "./adapters/#{name}"
  loadDirectory "#{process.cwd()}/adapters", withAdapter


loadAdapters
loadActors


exports.withActor = withActor
exports.withAdapter = withAdapter
exports.newActor = newActor
exports.newAdapter = newAdapter
