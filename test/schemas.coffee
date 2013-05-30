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
should = require("should")
factory = require "../lib/hfactory"

describe "schemas", ->
  hActor = undefined
  topology = undefined
  hMsg = undefined
  codes = require "../lib/codes"
  hubiquitus = require "../lib/hubiquitus"
  Actor = require "../lib/actor/hactor"

  beforeEach () ->
    topology = {
    actor: "urn:domain:actor",
    type: "hActor"
    }


  it "should bloc the starting of hubiquitus if there is a syntax error in the topology", (done) ->
    topology.actor = "Aurn:domain:actor"

    hubiquitus.start = (topology) ->
      result = hubiquitus.validator.validateTopology topology
      result.valid.should.be.false
      done()

    hubiquitus.start topology

  it "should emmit a warning during the reception of a hMessage if this one contains a syntax error (type not present)", (done) ->

    hMsg =
      msgid : UUID.generate()
      actor: "urn:domain:u1"
      priority: 0
      publisher: "urn:domain:actor"
      published: new Date().getTime()
      sent: new Date().getTime()

    hActor = new Actor topology

    hActor.send = (hMessage) ->
      hMessage.payload.status.should.be.equal(codes.hResultStatus.INVALID_ATTR)
      done()

    hActor.h_onMessageInternal hMsg

UUID = ->
UUID.generate = ->
  a = UUID._gri
  b = UUID._ha
  b(a(32), 8) + "-" + b(a(16), 4) + "-" + b(16384 | a(12), 4) + "-" + b(32768 | a(14), 4) + "-" + b(a(48), 12)
UUID._gri = (a) ->
  (if 0 > a then NaN else (if 30 >= a then 0 | Math.random() * (1 << a) else (if 53 >= a then (0 | 1073741824 * Math.random()) + 1073741824 * (0 | Math.random() * (1 << a - 30)) else NaN)))

UUID._ha = (a, b) ->
  c = a.toString(16)
  d = b - c.length
  e = "0"

  while 0 < d
    d & 1 and (c = e + c)
    d >>>= 1
    e += e
  c


