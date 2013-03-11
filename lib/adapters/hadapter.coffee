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

url = require "url"

#
# Class that defines an Adapter
#
class Adapter

  # @property {string}
  direction: undefined

  # @property {boolean}
  started: undefined

  # @property {object}
  properties: undefined

  # @property {Actor}
  owner: undefined

  #
  # Adapter's constructor
  # @param {object} properties
  #
  constructor: (properties) ->
    @started = false
    @properties = properties.properties
    if properties.owner
      @owner = properties.owner
    else
      throw new Error "You must pass an actor as reference"

  #
  # @param {string} url_string
  #
  formatUrl: (url_string) ->
    if url_string
      url_props = url.parse url_string
      if url_props.port
        @url = url_string
      else
        url_props.port = @genListenPort()
        delete url_props.host
        @url = url.format(url_props)
    else
      @url = "tcp://127.0.0.1:#{@genListenPort}"

  genListenPort: ->
    Math.floor(Math.random() * 30000) + 3000

  start: ->
    @started = true

  stop: ->
    @started = false

  update: (properties) ->
    # Function to overide if you need to update adapter's properties


#
# Class that defines an Inbound adapter
#
class InboundAdapter extends Adapter

  constructor: (properties) ->
    @direction = "in"
    super


#
# Class that defines an Outbound adapter
#
class OutboundAdapter extends Adapter

  # @property {string}
  targetActorAid: undefined

  constructor: (properties) ->
    @direction = "out"
    if properties.targetActorAid
      @targetActorAid = properties.targetActorAid
    else
      throw new Error "You must provide the AID of the targeted actor"
    super

  send: (message) ->
    throw new Error "Send method should be overriden"



exports.Adapter = Adapter
exports.InboundAdapter = InboundAdapter
exports.OutboundAdapter = OutboundAdapter
