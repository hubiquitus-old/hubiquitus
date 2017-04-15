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

exports.builtinActorNames =
  Actor: "hactor"
  Auth: "hauth"
  Channel: "hchannel"
  Dispatcher: "hdispatcher"
  Gateway: "hgateway"
  Session: "hsession"
  Tracker: "htracker"

exports.builtinAdapterNames =
  Adapter: "Adapter"
  InboundAdapter: "InboundAdapter"
  OutboundAdapter: "OutboundAdapter"
  ChannelInboundAdapter: "channel_in"
  ChannelOutboundAdapter: "channel_out"
  ChildprocessOutboundAdapter: "fork"
  HttpInboundAdapter: "http_in"
  HttpOutboundAdapter: "http_out"
  LocalOutboundAdapter: "inproc"
  LBSocketInboundAdapter: "lb_socket_in"
  LBSocketOutboundAdapter: "lb_socket_out"
  MongoOutboundAdapter: "mongo_out"
  CouchbaseOutboundAdapter: "couchbase_out"
  SocketInboundAdapter: "socket_in"
  SocketOutboundAdapter: "socket_out"
  SocketIOAdapter: "socketIO"
  TimerAdapter: "timerAdapter"
  TwitterInboundAdapter: "twitter_in"
  FilewatcherAdapter: "filewatcherAdapter"
  RestInboundAdapter: "rest_in"

exports.builtinAuthenticatorNames =
  Authenticator: "hauthenticator"
  SimpleAuthenticator: "simple"

exports.builtinFilterNames =
  Filter: "hfilter"

exports.builtinCodecNames =
  Codec: "hcodec"
  JSONCodec: "json"
  Base64Codec: "base64"

exports.builtinLoggerNames =
  Logger: "logger"
  ConsoleLogger: "console"
  FileLogger: "file"

