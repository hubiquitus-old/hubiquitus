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

winston = require "winston"
logger = new winston.Logger
  transports: [
    new winston.transports.Console(colorize: true)
  ]

validator = require "./validator"
filter = require "./hFilter"
codes = require "./codes"
factory = require "./hfactory"

# Set ZMQ_MAX_SOCKETS to the highest possible value because hubiquitus uses a lot of sockets.
if process.env.ZMQ_MAX_SOCKETS <= 0
  process.env.ZMQ_MAX_SOCKETS = 1000000

exports.Actor = require "./actor/hactor"
exports.Auth = require "./actor/hauth"
exports.Channel = require "./actor/hchannel"
exports.Dispatcher = require "./actor/hdispatcher"
exports.Gateway = require "./actor/hgateway"
exports.Session = require "./actor/hsession"
exports.Tracker = require "./actor/htracker"

exports.InboundAdapter = require("./adapters/hadapter").InboundAdapter
exports.OutboundAdapter = require("./adapters/hadapter").OutboundAdapter
exports.ChannelInboundAdapter = require "./adapters/channel_in"
exports.ChannelOutboundAdapter = require "./adapters/channel_out"
exports.ChildprocessOutboundAdapter = require "./adapters/fork"
exports.HttpInboundAdapter = require "./adapters/http_in"
exports.HttpOutboundAdapter = require "./adapters/http_out"
exports.LocalOutboundAdapter = require "./adapters/inproc"
exports.LBSocketInboundAdapter = require "./adapters/lb_socket_in"
exports.LBSocketOutboundAdapter = require "./adapters/lb_socket_out"
exports.SocketInboundAdapter = require "./adapters/socket_in"
exports.SocketOutboundAdapter = require "./adapters/socket_out"
exports.SocketIOAdapter = require "./adapters/socketIO"
exports.TimerAdapter = require "./adapters/timerAdapter"
exports.TwitterInboundAdapter = require "./adapters/twitter_in"

exports.validator = validator
exports.filter = filter
exports.codes = codes


exports.withActor = (type, actor) ->
  factory.withActor type, actor
  module.exports

exports.withAdapter = (type, adapter) ->
  factory.withAdapter type, adapter
  module.exports

exports.start = (topology) ->
  if not topology then topology = "topology"
  if typeof topology is "string" then topology = require "#{process.cwd()}/#{topology}"
  engine = factory.newActor topology.type, topology
  engine.on "hStatus", (status) ->
    if status is "started"
      logger.info "Hubiquitus started"
      process.on "SIGINT", ->
        engine.h_tearDown()
        process.exit()
  engine.h_start()
