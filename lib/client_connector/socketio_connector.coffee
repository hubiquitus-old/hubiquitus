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

fs = require "fs"
clients = {}
validator = require "../validator"
codes = require "../codes"

#
# Class that defines a socket-IO Connector (to connect a hAPI to a hEngine)
#
class SocketIO_Connector

  # @property {boolean} Connector's status
  started: undefined

  #
  # Connector's constructor. Create the websocket which be used by the socketIO adapter.
  # @param properties {object} Properties of the socket-IO connector
  #
  constructor: (properties) ->
    if properties.owner
    then @owner = properties.owner
    else throw new Error("You must pass an actor as reference")

    if properties.security
      server_options =
        key: fs.readFileSync(properties.security.key),
        cert: fs.readFileSync(properties.security.cert)
      server = require('https').createServer(server_options).listen(properties.port) #Creates the HTTPS server
      io = require("socket.io").listen(server)
    else
      io = require("socket.io").listen(properties.port) #Creates the HTTP server

    logLevels =
      DEBUG: 3
      INFO: 2
      WARN: 1
      ERROR: 0

    io.set "log level", logLevels[@owner.log_properties.logLevel]

    io.on("connection", (socket) =>
      id = socket.id
      clients[id] =
        id: id
        socket: socket

      socket.on "hConnect", (data) =>
        @connect clients[id], data

      socket.once "disconnect", =>
        @disconnect clients[id]

    )

  #
  # Method which connect the websocket
  # @param client {object} Reference to the client
  # @param data {object} Connexion data (urn, password)
  #
  connect: (client, data) ->
    unless client
      @owner.log "warn", "A client sent an invalid ID with data", data
      return
    @owner.log "info", "Client ID " + client.id + " sent connection data", data
    if not data or not data.login or not data.password
      @owner.log "info", "Client ID " + client.id + " is trying to connect without mandatory attribute", data
      return

    # Authentification
    @authenticate data, (actor, errorCode, errorMsg) =>
      if errorCode isnt codes.errors.NO_ERROR
        client.socket.emit 'hStatus', {status: codes.statuses.DISCONNECTED, errorCode: errorCode, errorMsg: errorMsg}
        @disconnect client
        return


      client.hClient = @owner
      inboundAdapters = []
      for inboundAdapter in @owner.inboundAdapters
        inboundAdapters.push {type:inboundAdapter.type, url:inboundAdapter.url}

      data.trackInbox = inboundAdapters
      data.actor = actor
      data.inboundAdapters
      session_type = @owner.properties.sessionType or "hsession"
      client.hClient.createChild session_type, "inproc", data, (child) =>
        #Relay all server status messages
        child.initListener(client)
        client.child = child.actor

  ###
  Try to authenticate a user
  ###
  authenticate: (data, cb) ->
    authTimeout = @owner.properties.authTimeout or 3000
    authMsg = @owner.buildMessage @owner.properties.authActor, "hAuth", {login: data.login, password: data.password, context: data.context},{timeout: authTimeout}
    @owner.send authMsg, (authResponse) =>
      if not authResponse or not authResponse.payload or not authResponse.payload.result
        cb undefined, codes.errors.TECH_ERROR, "invalid response"
        return

      authResult = authResponse.payload.result

      if authResult.errorCode isnt codes.errors.NO_ERROR
        cb undefined, authResult.errorCode, authResult.errorMsg
        return

      if not validator.validateURN authResult.actor
        cb undefined, codes.errors.URN_MALFORMAT, "urn malformat"
        return

      cb authResult.actor, codes.errors.NO_ERROR

  #
  # Method which disconnect the websocket
  # @param client {object} Reference to the client to close
  #
  disconnect: (client) ->
    if client and client.hClient
      @owner.log "debug", "Disconnecting Client " + client.publisher
      client.socket.disconnect()  if client.socket
      delete clients[client.id]
    else if client
      client.socket.disconnect()  if client.socket
      delete clients[client.id]

    @owner.send @owner.h_buildSignal(client.child, "stop", {}) if client.child

  #
  # Method called when the connector is started
  #
  start: ->
    @started = true

  #
  # Method called when the connector is stopping
  #
  stop: ->
    @started = false


module.exports = SocketIO_Connector
