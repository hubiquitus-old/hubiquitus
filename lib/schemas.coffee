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
      "pattern": /(^urn:[a-zA-Z0-9]{1}[a-zA-Z0-9\-.]+:[a-zA-Z0-9_,=@;!'%/#\(\)\+\-\.\$\*\?]+\/?.+$)/
    },
    "ip" : {
      "type" : "string",
      "description" : "It contains the IP of the actor",
      "pattern" : /(^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?).(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?).(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?).(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))|((([0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}:[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){5}:([0-9A-Fa-f]{1,4}:)?[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){4}:([0-9A-Fa-f]{1,4}:){0,2}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){3}:([0-9A-Fa-f]{1,4}:){0,3}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){2}:([0-9A-Fa-f]{1,4}:){0,4}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}((b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b).){3}(b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b))|(([0-9A-Fa-f]{1,4}:){0,5}:((b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b).){3}(b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b))|(::([0-9A-Fa-f]{1,4}:){0,5}((b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b).){3}(b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b))|([0-9A-Fa-f]{1,4}::([0-9A-Fa-f]{1,4}:){0,5}[0-9A-Fa-f]{1,4})|(::([0-9A-Fa-f]{1,4}:){0,6}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){1,7}:))$)/
    },
    "type" : {
      "type" : "string",
      "description": " It contains the name of the implementation used for the hActor."
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
              "pattern": /(^urn:[a-zA-Z0-9]{1}[a-zA-Z0-9\-.]+:[a-zA-Z0-9_,=@;!'%/#\(\)\+\-\.\$\*\?]+\/?.+$)/
            },
            "trackerUrl" : {
              "type" : "string",
              "description": "The url use to communicate with the hTracker."
            },
            "trackerChannel" : {
              "type" : "string",
              "description": "URN of the hTracker's channel.",
              "pattern": /(^urn:[a-zA-Z0-9]{1}[a-zA-Z0-9\-.]+:[a-zA-Z0-9_,=@;!'%/#\(\)\+\-\.\$\*\?]+\/?.+$)/
            }
          },
          "required" : ["trackerId", "trackerUrl", "trackerChannel"],
          "additionalProperties" : false
        }
      ],
      "additionalItems" : true
    },
    "loggers" : {
      "type" : "array",
      "description": "List of loggers used by the actor.",
      "items" : [
        {
          "type" : "object",
          "properties": {
            "type" : {
              "type" : "string",
              "description": "Type of the adapter."
            },
            "logLevel" : {
              "type" : "string",
              "description": "The loglevel used on the logger.",
              "enum": [ "error", "warn", "info", "debug", "trace" ]
            }
          },
          "required" : ["type"],
          "additionalProperties" : true
        }
      ],
      "additionalItems" : true
    },
    "adapters" : {
      "type" : "array",
      "description": "List of adapters used by the actor to communicate.",
      "items" : [
        {
          "type" : "object",
          "properties": {
            "type" : {
              "type" : "string",
              "description": "Type of the adapter."
            }
          },
          "required" : ["type"],
          "additionalProperties" : true
        }
      ],
      "additionalItems" : true
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
      "description": "List of children the actor will create.",
      "items" : [
        {
          "$ref" : "#",
          "additionalProperties" : true
        }
      ],
      "additionalItems" : true
    }
  },
  "required" : ["actor", "type"],
  "additionalProperties" : true
};

exports.hMessage = {
  "title": "hMessage",
  "description": "Messages form the relevant piece of information into a conversation.",
  "type": "object",
  "properties": {
    "msgid" : {
      "type" : "string",
      "description": "Provides a permanent, universally unique identifier for the message in the form of an absolute IRI."
    },
    "actor" : {
      "type" : "string",
      "description": "The URN through which the message is published ('urn:domain:actor').",
      "pattern": /(^urn:[a-zA-Z0-9]{1}[a-zA-Z0-9\-.]+:[a-zA-Z0-9_,=@;!'%/#\(\)\+\-\.\$\*\?]+\/?.+$)/
    },
    "convid" : {
      "type" : ["string","null"],
      "description": "The ID of the conversation to which the message belongs."
    },
    "ref" : {
      "type" : ["string","null"],
      "description": "Refers to another hMessage msgid. Provide a mechanism to do correlation between messages."
    },
    "type" : {
      "type" : "string",
      "description": "The type of the message payload."
    },
    "priority" : {
      "type" : ["integer","null"],
      "description": "The priority the hMessage."
    },
    "relevance" : {
      "type" : ["integer","null"],
      "description": "Defines the date (timestamp in milliseconds) until which the message is considered as relevant."
    },
    "persistent" : {
      "type" : ["boolean","null"],
      "description": "Indicates if the message MUST/MUST NOT be persisted by the middleware."
    },
    "location" : {
      "type" : ["object","null"],
      "description": "The geographical location to which the message refer."
    },
    "author" : {
      "type" : ["string","null"],
      "description": "The URN of the author (the object or device at the origin of the message)."
    },
    "publisher" : {
      "type" : "string",
      "description": "The URN of the client that effectively published the message (it can be different than the author).",
      "pattern": /(^urn:[a-zA-Z0-9]{1}[a-zA-Z0-9\-.]+:[a-zA-Z0-9_,=@;!'%/#\(\)\+\-\.\$\*\?]+\/?.+$)/
    },
    "published" : {
      "type" : ["integer","null"],
      "description": "The date (timestamp in milliseconds) at which the message has been published."
    },
    "headers" : {
      "type" : ["object","null"],
      "description": "A Headers object attached to this hMessage. It is a key-value pair map."
    },
    "payload" : {
      "type" : ["object","string","boolean","number","array","null"],
      "description": "The content of the message. It can be plain text or more structured data (HTML, XML, JSON, etc.)."
    },
    "timeout" : {
      "type" : ["integer","null"],
      "description": "Define the timeout (ms) to get an answer to the hMessage."
    },
    "sent" : {
      "type" : "integer",
      "description": "This attribute contains the creation date (timestamp in milliseconds) of the hMessage."
    }
  },
  "required" : ["msgid", "actor", "type", "publisher", "sent"],
  "additionalProperties" : false
};

exports.hCommand = {
  "title": "hCommand",
  "description": "The purpose of a hCommand payload is to execute an operation on a specific actor, a channel, a session.",
  "type": "object",
  "properties": {
    "cmd" : {
      "type" : "string",
      "description": "The name of the command to execute."
    },
    "params" : {
      "type" : "object",
      "description": "The parameters to pass to the command (as a JSON Object)."
    },
    "filter" : {
      "type" : "object",
      "ddescription" : "the filter for the hCommand"
    }
  },
  "required" : ["cmd"],
  "additionalProperties" : false
};

exports.hResult = {
  "title": "hResult",
  "description": "The purpose of a hResult payload is to respond to another hMessage.",
  "type": "object",
  "properties": {
    "status" : {
      "type" : "integer",
      "description": "The status of the operation."
    },
    "result" : {
      "type" : "object",
      "description": "The result of a command operation (can be undefined)."
    }
  },
  "required" : ["status"],
  "additionalProperties" : false
};


exports.hSignal = {
  "title": "hSignal",
  "description": "A hSignal is a service's hMessage. It is use to exchange internal message.",
  "type": "object",
  "properties": {
    "name" : {
      "type" : "string",
      "description": "The name of the signal."
    },
    "params" : {
      "type" : "object",
      "description": "The parameters to pass to the signal (as a JSON Object)."
    }
  },
  "required" : ["name", "params"],
  "additionalProperties" : false
};

exports.hGeo = {
  "title": "hGeo",
  "description": "Describe the exact longitude and latitude of a location.",
  "type": "object",
  "properties": {
    "lat" : {
      "type" : "number",
      "description": "Specifies the exact latitude of the location."
    },
    "lng" : {
      "type" : "number",
      "description": "Specifies the exact longitude of the location."
    }
  },
  "required" : ["lat", "lng"],
  "additionalProperties" : false
};