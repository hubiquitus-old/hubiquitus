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

allDot = new RegExp('\\.', 'g')

coreTypes =
# ---------------------------------------- Actors
  'hactor': './actors/hactor'
  'hauth': './actors/hauth'
  'hchannel': './actors/hchannel'
  'hgateway': './actors/hgateway'
  'hsession': './actors/hsession'
  'htracker': './actors/htracker'
# ---------------------------------------- Adapters
  'channel_in': './adapters/channel_in'
  'channel_out': './adapters/channel_out'
  'fork': './adapters/fork'
  'http_in': './adapters/http_in'
  'http_out': './adapters/http_out'
  'inproc': './adapters/inproc'
  'lb_socket_in': './adapters/lb_socket_in'
  'lb_socket_out': './adapters/lb_socket_out'
  'mongo_out': './adapters/mongo_out'
  'socket_in': './adapters/socket_in'
  'socket_out': './adapters/socket_out'
  'socketIO': './adapters/socketIO'
  'timerAdapter': './adapters/timerAdapter'
  'twitter_in': './adapters/twitter_in'
  'filewatcherAdapter': './adapters/filewatcherAdapter'
  'rest_in': './adapters/rest_in'
  'tingo_out': '.adapters/tingo_out'
# ---------------------------------------- Authenticators
  'simple': './authenticators/simple'
# ---------------------------------------- Filters
# ---------------------------------------- Codecs
  'json': './codecs/json'
  'base64': './codecs/base64'
# ---------------------------------------- Loggers
  'console': './loggers/console'
  'file': './loggers/file'


classes = {}

make = (type, properties) ->
  if not classes[type]
    if coreTypes[type]
      classes[type] = require coreTypes[type]
    else
      try
        classes[type] = require type.replace(allDot, '/')
      catch err
        classes[type] = require "#{process.cwd()}/#{type.replace(allDot, '/')}"

  new classes[type](properties)

exports.make = make
