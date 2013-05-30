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
# *    or substantilal portions of the Software.
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

codes = require("./codes").hResultStatus
log = require("winston")

exports.topology = {
  "title": "topology",
  "description": "topology describes every actor's attribute.",
  "type": "object",
  "properties": {
    "actor" : {
      "type" : "string",
      "description": "The URN of the actor. Used to identify the actor in the system.",
      "pattern": /(^urn:[a-zA-Z0-9]{1}[a-zA-Z0-9\-.]+:[a-zA-Z0-9_,=@;!'%/#\(\)\+\-\.\$\*\?]+\/?.+$)/,
      "required": true
    },
    "ip" : {
      "type" : "string",
      "description" : "It contains the IP of the actor",
      "pattern" : /^[1-2]?[0-9]{1,2}\.[1-2]?[0-9]{1,2}\.[1-2]?[0-9]{1,2}\.[1-2]?[0-9]{1,2}/,
    },
    "type" : {
      "type" : "string",
      "description": " It contains the name of the implementation used for the hActor.",
      "required": true
    },
    "method" : {
      "type" : "string",
      "description": "The method used to create the actor.",
      "enum": [ "inproc", "fork" ],
      "default": "inproc"
    },
    "trackers" : {
      "type" : "array",
      "description": "List the properties of all the hTracker of the system.",
      "items" : [
        {
          "type" : "object",
          "properties": {
            "trackerId" : {
              "type" : "string",
              "description": "URN of the hTracker.",
              "pattern": /(^urn:[a-zA-Z0-9]{1}[a-zA-Z0-9\-.]+:[a-zA-Z0-9_,=@;!'%/#\(\)\+\-\.\$\*\?]+\/?.+$)/,
              "required": true
            },
            "trackerUrl" : {
              "type" : "string",
              "description": "The url use to communicate with the hTracker.",
              "required": true
            },
            "trackerChannel" : {
              "type" : "string",
              "description": "URN of the hTracker's channel.",
              "pattern": /(^urn:[a-zA-Z0-9]{1}[a-zA-Z0-9\-.]+:[a-zA-Z0-9_,=@;!'%/#\(\)\+\-\.\$\*\?]+\/?.+$)/,
              "required": true
            }
          },
          "additionalProperties" : false
        }
      ],
      "additionalItems" : true
    },
    "log" : {
      "type" : "object",
      "description": "Configure the logger.",
      "properties": {
        "logLevel" : {
          "type" : "string",
          "description": "The log level used by the actor.",
          "enum": [ "error", "warn", "info", "debug" ]
        },
        "logFile" : {
          "type" : "string",
          "description": "Path to a logFile where you want to save the logs."
        }
      },
      "additionalProperties" : false
    },
    "adapters" : {
      "type" : "array",
      "description": "List of adapters used by the actor to communicate."
    },
    "sharedProperties" : {
      "type" : "object",
      "description": "The properties of the actor which are commons with all his children."
    },
    "properties" : {
      "type" : "object",
      "description": "The properties of the actor which depends of the type actor."
    },
    "children" : {
      "type" : "array",
      "description": "List of children the actor will create."
    }
  },
  "additionalProperties" : false
};

exports.hMessage = {
  "title": "hMessage",
  "description": "Messages form the relevant piece of information into a conversation.",
  "type": "object",
  "properties": {
    "msgid" : {
      "type" : "string",
      "description": "Provides a permanent, universally unique identifier for the message in the form of an absolute IRI.",
      "required": true
    },
    "actor" : {
      "type" : "string",
      "description": "The URN through which the message is published ('urn:domain:actor').",
      "pattern": /(^urn:[a-zA-Z0-9]{1}[a-zA-Z0-9\-.]+:[a-zA-Z0-9_,=@;!'%/#\(\)\+\-\.\$\*\?]+\/?.+$)/,
      "required": true
    },
    "convid" : {
      "type" : "string",
      "description": "The ID of the conversation to which the message belongs."
    },
    "ref" : {
      "type" : "string",
      "description": "Refers to another hMessage msgid. Provide a mechanism to do correlation between messages."
    },
    "type" : {
      "type" : "string",
      "description": "The type of the message payload.",
      "required": true
    },
    "priority" : {
      "type" : "integer",
      "description": "The priority the hMessage."
    },
    "relevance" : {
      "type" : "integer",
      "description": "Defines the date (timestamp in milliseconds) until which the message is considered as relevant."
    },
    "persistent" : {
      "type" : "boolean",
      "description": "Indicates if the message MUST/MUST NOT be persisted by the middleware."
    },
    "location" : {
      "type" : "object",
      "description": "The geographical location to which the message refer."
    },
    "author" : {
      "type" : "string",
      "description": "The URN of the author (the object or device at the origin of the message)."
    },
    "publisher" : {
      "type" : "string",
      "description": "The URN of the client that effectively published the message (it can be different than the author).",
      "pattern": /(^urn:[a-zA-Z0-9]{1}[a-zA-Z0-9\-.]+:[a-zA-Z0-9_,=@;!'%/#\(\)\+\-\.\$\*\?]+\/?.+$)/,
      "required": true
    },
    "published" : {
      "type" : "integer",
      "description": "The date (timestamp in milliseconds) at which the message has been published.",
      "required": true
    },
    "headers" : {
      "type" : "object",
      "description": "A Headers object attached to this hMessage. It is a key-value pair map."
    },
    "payload" : {
      "type" : {"object","string"},
      "description": "The content of the message. It can be plain text or more structured data (HTML, XML, JSON, etc.)."
    },
    "timeout" : {
      "type" : "integer",
      "description": "Define the timeout (ms) to get an answer to the hMessage."
    },
    "sent" : {
      "type" : "integer",
      "description": "This attribute contains the creation date (timestamp in milliseconds) of the hMessage."
    }
  },
  "additionalProperties" : false
};

exports.hCommand = {
  "title": "hCommand",
  "description": "The purpose of a hCommand payload is to execute an operation on a specific actor, a channel, a session.",
  "type": "object",
  "properties": {
    "cmd" : {
      "type" : "string",
      "description": "The name of the command to execute.",
      "required": true
    },
    "params" : {
      "type" : "object",
      "description": "The parameters to pass to the command (as a JSON Object)."
    }
  },
  "additionalProperties" : false
};

exports.hResult = {
  "title": "hResult",
  "description": "The purpose of a hResult payload is to respond to another hMessage.",
  "type": "object",
  "properties": {
    "status" : {
      "type" : "integer",
      "description": "The status of the operation.",
      "required": true
    },
    "result" : {
      "type" : "object",
      "description": "The result of a command operation (can be undefined)."
    }
  },
  "additionalProperties" : false
};


exports.hSignal = {
  "title": "hSignal",
  "description": "A hSignal is a service's hMessage. It is use to exchange internal message.",
  "type": "object",
  "properties": {
    "name" : {
      "type" : "string",
      "description": "The name of the signal.",
      "required": true
    },
    "params" : {
      "type" : "object",
      "description": "The parameters to pass to the signal (as a JSON Object).",
      "required": true
    }
  },
  "additionalProperties" : false
};

exports.hLocation = {
  "title": "hLocation",
  "description": "Describe a geographical location.",
  "type": "object",
  "properties": {
    "pos" : {
      "type" : "hGeo",
      "description": "Specifies the exact longitude and latitude of the location.",
      "required": true
    },
    "num" : {
      "type" : "string",
      "description": "Specifies the way number of the address.",
      "required": true
    },
    "wayType" : {
      "type" : "string",
      "description": "Specifies the type of the way.",
      "required": true
    },
    "way" : {
      "type" : "string",
      "description": "Specifies the name of the street/way.",
      "required": true
    },
    "addr" : {
      "type" : "string",
      "description": "Specifies address complement.",
      "required": true
    },
    "floor" : {
      "type" : "string",
      "description": "Specifies the floor number of the address.",
      "required": true
    },
    "building" : {
      "type" : "string",
      "description": "Specifies the building’s identifier of the address.",
      "required": true
    },
    "zip" : {
      "type" : "string",
      "description": "Specifies a zip code for the location.",
      "required": true
    },
    "city" : {
      "type" : "string",
      "description": "Specifies a city.",
      "required": true
    },
    "countryCode" : {
      "type" : "string",
      "description": "Specifies a country code.",
      "required": true
    }
  },
  "additionalProperties" : false
};

exports.hGeo = {
  "title": "hGeo",
  "description": "Describe the exact longitude and latitude of a location.",
  "type": "object",
  "properties": {
    "lat" : {
      "type" : "number",
      "description": "Specifies the exact longitude of the location.",
      "required": true
    },
    "lng" : {
      "type" : "number",
      "description": "Specifies the exact latitude of the location.",
      "required": true
    }
  },
  "additionalProperties" : false
};

exports.hPos = {
  "title": "hPos",
  "description": "This structure defines an area around a specific location.",
  "type": "object",
  "properties": {
    "lat" : {
      "type" : "number",
      "description": "Specifies the exact latitude of the location.",
      "required": true
    },
    "lng" : {
      "type" : "number",
      "description": "Specifies the exact longitude of the location.",
      "required": true
    },
    "radius" : {
      "type" : "integer",
      "description": "The radius expressed in meter.",
      "required": true
    }
  },
  "additionalProperties" : false
};