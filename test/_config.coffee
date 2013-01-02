user1Urn = 'urn:localhost:u1'
user1Pass = 'u1'

user2Urn = 'urn:localhost:u2'
user2Pass = 'u2'

mongoURI = 'mongodb://localhost/test'

commandsPath = 'lib/hcommands'
commandsTimeout = 5000

# * Don't edit below * #

# * available vars * #
# Available external classes
exports.validators = undefined
exports.codes = undefined
exports.db = undefined

# Available vars
exports.logins = undefined
exports.cmdParams = undefined
exports.mongoURI = undefined
exports.validURN = undefined
exports.validDomain = undefined


# Available functions
exports.makeHMessage = undefined
exports.createChannel = undefined
exports.beforeFN = undefined
exports.afterFN = undefined



###
DO NOT TOUCH BELOW THIS LINE
###


should = require('should')
codes = require('../lib/codes')

validators = require('../lib/validator')
winston = require('winston')

db = require('../lib/dbPool').getDbPool().getDb("admin");

exports.validators = validators
exports.db = db
exports.codes = codes

validURN = 'urn:localhost:u1'

# Array of logins (with params if you want) to connect to XMPP
exports.logins = [
  {
    urn: user1Urn,
    password: user1Pass
  },
  {
    urn: user1Urn + '/testRessource',
    password: user1Pass
  },
  {
    urn: user2Urn,
    password: user1Pass
  },
  {
    urn: user2Urn + '/testRessource',
    password: user1Pass
  }
];

exports.cmdParams = {
  modulePath: commandsPath,
  timeout: commandsTimeout
}

exports.mongoURI = mongoURI

exports.validURN = validURN;

exports.validDomain = exports.validators.getDomainURN(validURN);


exports.makeHMessage = (actor, publisher, type, payload) ->
  hMessage =
    msgid: UUID.generate()
    convid: undefined
    actor: actor
    type: type
    priority: 0
    publisher: publisher
    published: new Date().getTime()
    sent: new Date().getTime()
    timeout: 30000
    payload: payload

  hMessage.convid = hMessage.msgid
  hMessage

exports.createChannel = (actor, subscribers, owner, active) ->
  payload =
    cmd: "hCreateUpdateChannel"
    params:
      type: "channel"
      actor: actor
      active: active
      owner: owner
      subscribers: subscribers

  exports.makeHMessage(owner, owner, "hCommand", payload)

exports.getUUID = () ->
  UUID.generate()

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