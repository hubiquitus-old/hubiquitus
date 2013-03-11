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

###
hEcho receives an hCommand and responds with a result
with the same <params> that were in the hCommand.
###
status = require("../codes").hResultStatus
hEcho = ->


  ###
  Method executed each time an hCommand with cmd = 'hEcho' is received.
  Once the execution finishes we should call the callback.
  @param hMessage - hMessage with hCommand received with cmd = 'hEcho'
  @param context - Auxiliary functions,attrs from the controller.
  @param cb(status, result) - function that receives arg:
  status: //Constant from var status to indicate the result of the hCommand
  result: //An optional result object defined by the hCommand
  ###
hEcho::exec = (hMessage, context, cb) ->
  hcommand = hMessage.payload

  #For test purpose
  if hcommand.params.error is "DIV0"
    div = "12 / 0"
    div.push div
  cb status.OK, hcommand.params


###
Expose hEcho
###
exports.Command = hEcho