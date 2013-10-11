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

os = require "os"
_ = require "underscore"
lodash = require "lodash"


exports.ip = () ->
  interfaces = os.networkInterfaces()
  if interfaces
    sortIntName = Object.getOwnPropertyNames(interfaces).sort (int1, int2) =>
      regxType = /^([^0-9]+)([0-9]+)$/
      regx1 = int1.match regxType
      regx2 = int2.match regxType
      if regx1
        type1 = regx1[1]
        num1 = regx1[2]
      else
        type1 = int1
        num1 = 0
      if regx2
        type2 = regx2[1]
        num2 = regx2[2]
      else
        type2 = int2
        num2 = 0

      if type1 is type2
        if num1 > num2 then return 1
        else return -1
      else
        list = ["eth", "en", "wlan", "vmnet", "ppp", "lo"]
        if list.indexOf(type1) > list.indexOf(type2) then return 1
        else return -1

    for intName in sortIntName
      if interfaces[intName]
        for net in interfaces[intName]
          if net.family is "IPv4"
            return net.address
  else
    return "127.0.0.1"
