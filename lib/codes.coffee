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

exports.errors =
  NO_ERROR: 0
  URN_MALFORMAT: 1
  CONN_TIMEOUT: 2
  AUTH_FAILED: 3
  ALREADY_CONNECTED: 5
  TECH_ERROR: 6
  NOT_CONNECTED: 7
  CONN_PROGRESS: 8

exports.statuses =
  CONNECTING: 1
  CONNECTED: 2
  DISCONNECTING: 5
  DISCONNECTED: 6

exports.hResultStatus =
  OK: 0
  TECH_ERROR: 1
  NOT_CONNECTED: 3
  NOT_AUTHORIZED: 5
  MISSING_ATTR: 6
  INVALID_ATTR: 7
  NOT_AVAILABLE: 9
  EXEC_TIMEOUT: 10

exports.mongoCodes =
  DISCONNECTED: 0
  CONNECTED: 1
  TECH_ERROR: 4
  INVALID_URI: 5