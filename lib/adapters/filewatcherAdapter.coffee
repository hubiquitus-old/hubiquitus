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
InboundAdapter = require "./InboundAdapter"
fs = require "fs"

#
# Class that definefilewatchs a Filwatch Inbound Adapter
# This Adapter send the value of an object property to the actor each time the file is modified
#
class FilewatcherAdapter extends InboundAdapter

  #
  # Adapter's constructor
  # @param properties {object} Launch properties of the adapter, The file Path to watch
  #
  constructor: (properties) ->
    super
    if @properties.path
      @path = @properties.path
      fs.exists(@path, (exists) =>
        if exists is false
          @owner.log "debug", "FilewatcherAdapter : The File doesnt exist")
    else
      @owner.log "debug", "FilewatcherAdapter : Waiting for a path"
    @type = "Filewatcher"


  #
  # Method which read the correspondant file
  # When the file is modified, we convert it in a hMessage and send the property we need to the actor
  #
  watch: () ->
    fs.watchFile @path,{persistent:"false", interval:"500"}, (hMessage) =>
      fs.readFile @path, (err, data) =>
        unless err
          @receive data


  #
  # @overload start()
  # Method which start the adapter.
  # When the adapter is started, the actor can receive a hMessage
  #
  start: () ->
    while @started is false
      super
      @owner.log "info","Watching : " + @path
      @watch()

  #
  # @overload h_fillMessage()
  # Method which fills a hMessage.
  #
  h_fillMessage: (hMessage, callback) ->
    hMessage.actor = hMessage.actor or @owner.actor
    hMessage.publisher = hMessage.publisher or @owner.actor
    hMessage.type = hMessage.type or "filePayload"
    super

  #
  # @overload stop()
  # Method which stop the adapter.
  # When the adapter is stoped, the actor can not receive a hMessage anymore
  #
  stop: ->
    if @started
      fs.unwatchFile "@path"


module.exports = FilewatcherAdapter
