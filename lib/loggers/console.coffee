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
Logger = require "./logger"
winston = require "winston"

# winston console logger singleton
logger = undefined

#
# Class that defines a console logger
# Console logger is uniq for a process
#
class ConsoleLogger extends Logger

  #
  # Console logger's constructor
  #
  constructor: (properties) ->
    super
    unless logger
      loggerLevels = {"levels":{trace: 0, debug: 1, info: 2, warn: 3, error: 4}, colors: {trace: 'grey', debug: 'blue', info: 'green', warn: 'yellow', error:'red'}}
      logger = new (winston.Logger) {transports: [new (winston.transports.Console)({"level": "trace", "colorize": true})], levels: loggerLevels.levels, colors: loggerLevels.colors}
      logger.exitOnError = false

  #
  # @param level {string} log level of the message. Available levels are : trace, debug, info, warn, error
  # @param urn {string} urn of the logger's owner.
  # @param errid {string} unique error id
  # @param msgs {function} message to log
  #
  log: (level, urn, errid, msgs) ->
    logger[level] @makeLogMsg level, urn, errid, msgs

module.exports = ConsoleLogger
