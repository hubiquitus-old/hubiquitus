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
config = require("./_config")
_ = require "underscore"

describe "hGateway", ->
  hActor = undefined
  status = require("../lib/codes").hResultStatus
  actorModule = require("../lib/actor/hgateway")
  socket = undefined

  describe "socket IO with ssl", ->
    before () ->
      topology = {
        actor: "urn:localhost:gateway",
        type: "hgateway",
        method: "inproc",
        children: [
          {
            actor: "urn:localhost:auth",
            type: "hauth",
            method: "inproc"
          }
        ],
        adapters: [ { type: "socket_in", url: "tcp://127.0.0.1:3993" } ],
        properties: {
          security: {
            key: "./ssl/server.key.pem",
            cert: "./ssl/server.crt.pem"
          },
          socketIOPort: 8080,
          authActor: "urn:localhost:auth",
          authTimeout: 3000
          }
      }
      hActor = actorModule.newActor(topology)

    after () ->
      socket.disconnect()
      hActor.h_tearDown()
      hActor = null

    it "should not connect without ssl", (done) ->
      socket = require("socket.io-client").connect("http://localhost:8080")
      socket.on 'error', (error) =>
        error.should.match(/socket hang up/)
        done()

    it "should connect with ssl", (done) ->
      socket = require("socket.io-client").connect("https://localhost:8080")
      socket.on 'connect', =>
        done()

  describe "socket IO without ssl", ->
    before () ->
      topology = {
        actor: "urn:localhost:gateway",
        type: "hgateway",
        method: "inproc",
        children: [
          {
          actor: "urn:localhost:auth",
          type: "hauth",
          method: "inproc"
          }
        ],
        adapters: [ { type: "socket_in", url: "tcp://127.0.0.1:3993" } ],
        properties: {
          socketIOPort: 8081,
          authActor: "urn:localhost:auth",
          authTimeout: 3000
        }
      }
      hActor = actorModule.newActor(topology)

    after () ->
      hActor.h_tearDown()
      hActor = null

    it "should not connect with ssl", (done) ->
      socket = require("socket.io-client").connect("https://localhost:8081")
      socket.on 'error', (error) =>
        error.should.match(/socket hang up/)
        done()

    it "should connect without ssl", (done) ->
      socket = require("socket.io-client").connect("http://localhost:8081")
      socket.on 'connect', =>
        done()

