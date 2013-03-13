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

fs = require "fs"
adapters = require "./adapters/hAdapters"
Actor = require "./actor/hactor"
os = require "os"
_ = require "underscore"

createActor = (properties) ->
  actorModule = require "#{__dirname}/actor/#{properties.type}"
  actor = new actorModule properties

main = ->

  topologyPath = process.argv[2] or "samples/sample1.json"
  hTopology = `undefined`
  try
    hTopology = eval("(" + fs.readFileSync(topologyPath, "utf8") + ")")
  catch err
    console.log "erreur : ",err
  unless hTopology
    console.log "No config file or malformated config file. Can not start actor"
    process.exit 1


  mockActor = { actor: "process"+process.pid }

  engine = createActor(hTopology)

  engine.on "started", ->
    _.forEach ["SIGINT"], (signal) ->
      process.on signal, ->
        engine.h_tearDown()
        process.exit()
     #   clearInterval interval

  # starting engine
  engine.h_start()

main()