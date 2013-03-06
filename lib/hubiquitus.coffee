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

{Actor} = require "./actor/hactor"
{Auth} = require "./actor/hauth"
{Channel} = require "./actor/hchannel"
{Dispatcher} = require "./actor/hdispatcher"
{Gateway} = require "./actor/hgateway"
{Session} = require "./actor/hsession"
{Tracker} = require "./actor/htracker"

{InboundAdapter} = require "./adapters/hadapter"
{OutboundAdapter} = require "./adapters/hadapter"
{ChannelInboundAdapter} = require "./adapters/channel_in"
{ChannelOutboundAdapter} = require "./adapters/channel_out"
{ChildprocessOutboundAdapter} = require "./adapters/fork"
{HttpInboundAdapter} = require "./adapters/http_in"
{HttpOutboundAdapter} = require "./adapters/http_out"
{LocalOutboundAdapter} = require "./adapters/inproc"
{LBSocketInboundAdapter} = require "./adapters/lb_socket_in"
{LBSocketOutboundAdapter} = require "./adapters/lb_socket_out"
{SocketInboundAdapter} = require "./adapters/socket_in"
{SocketOutboundAdapter} = require "./adapters/socket_out"
{SocketIOAdapter} = require "./adapters/socketIO"
{TimerAdapter} = require "./adapters/timerAdapter"
{TwitterInboundAdapter} = require "./adapters/twitter_in"

validator = require "./validator"
filter = require "./hFilter"
codes = require "./codes"
factory = require "./hfactory"
_ = require "underscore"

exports.Actor = Actor
exports.Auth = Auth
exports.Channel = Channel
exports.Dispatcher = Dispatcher
exports.Gateway = Gateway
exports.Session = Session
exports.Tracker = Tracker

exports.InboundAdapter = InboundAdapter
exports.OutboundAdapter = OutboundAdapter
exports.ChannelInboundAdapter = ChannelInboundAdapter
exports.ChannelOutboundAdapter = ChannelOutboundAdapter
exports.ChildprocessOutboundAdapter = ChildprocessOutboundAdapter
exports.HttpInboundAdapter = HttpInboundAdapter
exports.HttpOutboundAdapter = HttpOutboundAdapter
exports.LocalOutboundAdapter = LocalOutboundAdapter
exports.LBSocketInboundAdapter = LBSocketInboundAdapter
exports.LBSocketOutboundAdapter = LBSocketOutboundAdapter
exports.SocketInboundAdapter = SocketInboundAdapter
exports.SocketOutboundAdapter = SocketOutboundAdapter
exports.SocketIOAdapter = SocketIOAdapter
exports.TimerAdapter = TimerAdapter
exports.TwitterInboundAdapter = TwitterInboundAdapter

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
  engine.on "started", ->
    process.on "SIGINT", ->
      engine.h_tearDown()
      process.exit()
  engine.h_start()
