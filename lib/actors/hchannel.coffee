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
Actor = require "./hactor"
zmq = require "zmq"
_ = require "lodash"
validator = require "../validator"
codes = require "../codes"
factory = require "../factory"

#
# Class that defines a channel actor
#
class Channel extends Actor

  #
  # Actor's constructor
  # @param topology {object} Launch topology of the actor
  #
  constructor: (topology) ->
    #TODO Stop actor and send error when all mandatory attribut is not in topology
    super
    @type = "channel"
    @inboundAdapters.push factory.make("socket_in", {url: @properties.listenOn, owner: @})
    @outboundAdapters.push factory.make("channel_out", {url: @properties.broadcastOn, owner: @, targetActorAid: @actor})
    @properties.subscribers = topology.properties.subscribers or []
    if topology.properties.persistentAid
      @persistentAid = topology.properties.persistentAid

  #
  # @overload onMessage(hMessage)
  #   Method that processes the incoming message on a hChannel.
  #   @param hMessage {Object} the hMessage receive
  #
  onMessage: (hMessage) ->
    # If hCommand, execute it
    if hMessage.type is "hCommand" and validator.getBareURN(hMessage.actor) is validator.getBareURN(@actor)
      switch hMessage.payload.cmd
        when "hSubscribe"
          command = require("./../hcommands/hSubscribe").Command
          module = new command()
          @runCommand(hMessage, module)
        else
          hMessageResult = @buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.NOT_AVAILABLE, "Command not available for this actor")
          @send hMessageResult
    # If other type, publish
    else
      if hMessage.persistent is true and @persistentAid isnt undefined
        persistMsg = _.omit hMessage, 'persistent', 'timeout'
        persistMsg.actor = @persistentAid
        @send persistMsg

      #sends to all subscribers the message received
      hMessage.actor = @actor
      @send hMessage
      if hMessage.timeout > 0
        hMessageResult = @buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.OK, hMessage)
        @send hMessageResult

  #
  # @overload h_onSignal(hMessage)
  #   Private method that processes hSignal message.
  #   The hSignal are service's message
  #   @private
  #   @param hMessage {object} the hSignal receive
  #
  h_onSignal: (hMessage) ->
    @log "trace", "Channel received a hSignal:", hMessage
    if hMessage.payload.name is "hStopAlert"
      hMessage.actor = @actor
      @send hMessage

  #
  # Method that Loads the hCommand module, sets the listener.
  # @param hMessage {object} The received hMessage with a hCommand payload
  # @param module {object} Module calls to run command
  #
  runCommand: (hMessage, module) ->
    self = this
    timerObject = null #setTimeout timer variable
    commandTimeout = null #Time in ms to wait to launch timeout
    hMessageResult = undefined
    hCommand = hMessage.payload

    #check hCommand
    if not hCommand or typeof hCommand isnt "object"
      @send self.buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.INVALID_ATTR, "Invalid payload. Not an hCommand")
      return
    if not hCommand.cmd or typeof hCommand.cmd isnt "string"
      @send self.buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.INVALID_ATTR, "Invalid command. Not a string")
      return
    if hCommand.params and typeof hCommand.params isnt "object"
      @send self.buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.INVALID_ATTR, "Invalid command. Params is settled but not an object")
      return
    commandTimeout = module.timeout or 5000

    onResult = (status, result) =>
      #If callback is called after the timer ignore it
      return  unless timerObject?
      clearTimeout timerObject
      hMessageResult = self.buildResult(hMessage.publisher, hMessage.msgid, status, result)
      @log "trace", "hCommand sent hMessage with hResult", hMessageResult
      @send hMessageResult

    #Add a timeout for the execution
    timerObject = setTimeout(=>
      #Set it to null to test if send is executed after timeout
      timerObject = null
      hMessageResult = self.buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.EXEC_TIMEOUT,"")
      @log "debug", "hCommand sent hMessage with exceed timeout error", hMessageResult
      @send hMessageResult
    , commandTimeout)

    #Run it!
    try
      module.exec hMessage, @, onResult
    catch err
      clearTimeout timerObject
      @log "error", "Error in hCommand processing, hMessage = ", hMessage, " with error : ", err
      @send(@buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.TECH_ERROR, "error processing message : " + err))

  #
  # @overload h_fillAttribut(hMessage, cb)
  #   Method called to override some hMessage's attributs before sending.
  #   Overload the hActor method with an empty function to not altering a hMessage publish in a channel
  #   @private
  #
  h_fillAttribut: (hMessage, cb) ->
    #Override with empty function to not altering hMessage
    hMessage.sent = new Date().getTime()


module.exports = Channel
