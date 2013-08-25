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

#
# Class that defines a Logger
#
class Logger

  # @property {object} Logger's properties
  properties: undefined

  # @property {string} Logger's log level
  logLevel: undefined

  # @property {number} Logger's log level as a numerical value.
  level: undefined

  # @property {Actor} Logger's owner
  owner: undefined

  #
  # Logger's constructor
  # @param properties {object} logger properties provide by actor. Expect two key : properties, logLevel.
  #
  constructor: (properties) ->
    @properties = properties.properties or {}
    @logLevel = properties.logLevel or "info"

    if properties.owner
      @owner = properties.owner
    else
      throw new Error "You must pass an actor as reference"

  #
  # @param level {string} log level of the message. Available levels are : trace, debug, info, warn, error
  # @param urn {string} urn of the logger's owner.
  # @param msgs {function} messages to log (stringify should be done at logger level if needed)
  #
  log: (level, urn, msgs) ->

module.exports = Logger