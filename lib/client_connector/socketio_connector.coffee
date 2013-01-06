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

log = require("winston")
clients = {}
options = require("../options").sioConnector
validator = require "../validator"
codes = require "../codes"

class SocketIO_Connector
  ###
  Runs a SocketIO Connector with the given arguments.
  @param args - {
  logLevel : DEBUG, INFO, WARN or ERROR
  port : int
  commandOptions : {} Command Controller Options
  }
  ###
  constructor: (properties) ->
    if properties.owner
    then @owner = properties.owner
    else throw new Error("You must pass an actor as reference")

    io = require("socket.io").listen(properties.port) #Creates the HTTP server

    logLevels =
      DEBUG: 3
      INFO: 2
      WARN: 1
      ERROR: 0

    io.set "log level", logLevels[options.logLevel]

    channel = io.on("connection", (socket) =>
      id = socket.id
      clients[id] =
        id: id
        socket: socket

      socket.on "hConnect", (data) =>
        @connect clients[id], data

      socket.once "disconnect", =>
        @disconnect clients[id]

    )

  ###
  @param client - Reference to the client
  @param data - Expected {urn, password}
  ###
  connect: (client, data) ->
    unless client
      log.warn "A client sent an invalid ID with data", data
      return
    log.info "Client ID " + client.id + " sent connection data", data
    if not data or not data.login or not data.password
      log.info "Client ID " + client.id + " is trying to connect without mandatory attribute", data
      return

    # Authentification
    authTimeout = @owner.properties.authTimeout or 3000
    authMsg = @owner.buildMessage @owner.properties.authActor, "hAuth", {login: data.login, password: data.password, context: data.context},{timeout: authTimeout}
    @owner.send authMsg, (authResponse) =>
      if not authResponse or not authResponse.payload or not authResponse.payload.result
        client.socket.emit 'hStatus', {status: codes.statuses.DISCONNECTED, errorCode: codes.errors.TECH_ERROR, errorMsg: "invalid response"}
        @disconnect client
        return

      authResult = authResponse.payload.result

      if authResult.errorCode isnt codes.errors.NO_ERROR
        client.socket.emit 'hStatus', { status: codes.statuses.DISCONNECTED, errorCode: authResult.errorCode, errorMsg: authResult.errorMsg}
        @disconnect client
        return

      if not validator.validateURN authResult.actor
        log.debug "Disconnecting with error Client " + client.publish
        client.socket.emit 'hStatus', { status: codes.statuses.DISCONNECTED, errorCode: codes.errors.URN_MALFORMAT}
        @disconnect client
        return

      client.hClient = @owner
      inboundAdapters = []
      for inboundAdapter in @owner.inboundAdapters
        inboundAdapters.push {type:inboundAdapter.type, url:inboundAdapter.url}

      data.trackInbox = inboundAdapters
      data.actor = authResult.actor
      data.inboundAdapters
      client.hClient.createChild "hsession", "inproc", data, (child) =>
        #Relay all server status messages
        child.initListener(client)
        client.child = child.actor

  ###
  Disconnects the current session and socket.
  @param client - Reference to the client to close
  ###
  disconnect: (client) ->
    if client and client.hClient
      log.debug "Disconnecting Client " + client.publisher
      client.socket.disconnect()  if client.socket
      delete clients[client.id]
    else if client
      client.socket.disconnect()  if client.socket
      delete clients[client.id]

    @owner.send @owner.buildSignal(client.child, "stop", {}) if client.child


  start: ->
    @started = true

  stop: ->
    @started = false


exports.socketIO = (properties) ->
  new SocketIO_Connector(properties)
