Hubiquitus use a few structure to run :

# Message Structure

## hMessage
* Messages form the relevant piece of information into a conversation.
* Messages cannot be modified after having been published, except to specify the ID of the conversation (convid) for a conversation started from an already published message.

### Expected attributes of a hMessage :

<table>
    <thead>
        <tr>
            <th>Property</th>
            <th>Type</th>
            <th>Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>msgid</td>
            <td>String</td>
            <td>Provides a permanent, universally unique identifier for the message in the form of an absolute IRI</td>
            <td>Yes <sup>(1)</sup></td>
        </tr>
        <tr>
            <td>actor</td>
            <td>String</td>
            <td>The URN through which the message is published ("urn:domain:actor")</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>convid</td>
            <td>String</td>
            <td>The ID of the conversation to which the message belongs</td>
            <td>No</td>
        </tr>
        <tr>
            <td>ref</td>
            <td>String</td>
            <td>Refers to another hMessage msgid. Provide a mechanism to do correlation between messages</td>
            <td>No</td>
        </tr>
        <tr>
             <td>type</td>
             <td>String</td>
             <td>The type of the message payload</td>
             <td>Yes</td>
        </tr>
        <tr>
             <td>priority</td>
             <td>Int</td>
             <td>The priority the hMessage</td>
             <td>No</td>
        </tr>
        <tr>
            <td>relevance</td>
            <td>Date</td>
            <td>Defines the date (timestamp in milliseconds) until which the message is considered as relevant</td>
            <td>No</td>
        </tr>
        <tr>
            <td>persistent</td>
            <td>Boolean</td>
            <td>Indicates if the message MUST/MUST NOT be persisted by the middleware</td>
            <td>No</td>
        </tr>
        <tr>
            <td>location</td>
            <td>hLocation</td>
            <td>The geographical location to which the message refer</td>
            <td>No</td>
        </tr>
        <tr>
            <td>author</td>
            <td>String</td>
            <td>The URN of the author (the object or device at the origin of the message)</td>
            <td>No</td>
        </tr>
        <tr>
            <td>publisher</td>
            <td>String</td>
            <td>The URN of the client that effectively published the message (it can be different than the author)</td>
            <td>Yes <sup>(4)</sup></td>
        </tr>
        <tr>
            <td>published</td>
            <td>Date</td>
            <td>The date (timestamp in milliseconds) at which the message has been published</td>
            <td>Yes <sup>(3)</sup></td>
        </tr>
        <tr>
            <td>headers</td>
            <td>hHeader</td>
            <td>A Headers object attached to this hMessage. It is a key-value pair map</td>
            <td>No</td>
        </tr>
        <tr>
            <td>payload</td>
            <td>Object or string</td>
            <td>The content of the message. It can be plain text or more structured data (HTML, XML, JSON, etc.)</td>
            <td>No</td>
        </tr>
        <tr>
            <td>timeout</td>
            <td>Int</td>
            <td>Define the timeout (ms) to get an answer to the hMessage</td>
            <td>No</td>
        </tr>
        <tr>
            <td>sent</td>
            <td>Date</td>
            <td>This attribute contains the creation date (timestamp in milliseconds) of the hMessage</td>
            <td>No</td>
        </tr>
    </tbody>
</table>
```
(1)  Can be filled by the hAPI or any actor
(2)  Can be filled by any actor
(3)  Can be filled by the hAPI
(4)  Filled when the hMessage is send
```

# Message Payload Structure
## hCommand
* The purpose of a hCommand payload is to execute an operation on a specific actor, a channel, a session (eg. hAPI case).

### Expected attributes of a hCommand :

<table>
    <thead>
        <tr>
            <th>Property</th>
            <th>Type</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>cmd</td>
            <td>String</td>
            <td>The name of the command to execute</td>
        </tr>
        <tr>
            <td>params</td>
            <td>Object</td>
            <td>The parameters to pass to the command (as a JSON Object)</td>
        </tr>
    </tbody>
</table>

## hResult
* The purpose of a hResult payload is to respond to another hMessage

### Expected attributes of a hResult :

<table>
    <thead>
        <tr>
            <th>Property</th>
            <th>Type</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>status</td>
            <td>Int</td>
            <td>The status of the operation</td>
        </tr>
        <tr>
            <td>result</td>
            <td>Object</td>
            <td>The result of a command operation (can be undefined)</td>
        </tr>
    </tbody>
</table>

## hSignal
* A hSignal is a service's hMessage. It is use to exchange internal message.

### Expected attributes of a hSignal :

<table>
    <thead>
        <tr>
            <th>Property</th>
            <th>Type</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>name</td>
            <td>String</td>
            <td>The name of the signal</td>
        </tr>
        <tr>
            <td>params</td>
            <td>Object</td>
            <td>The parameters to pass to the signal (as a JSON Object)</td>
        </tr>
    </tbody>
</table>

# Metadata Structure
## hLocation
* Describe a geographical location

### Expected attributes of a hLocation :

<table>
    <thead>
        <tr>
            <th>Property</th>
            <th>Type</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>pos</td>
            <td>hGeo</td>
            <td>Specifies the exact longitude and latitude of the location</td>
        </tr>
        <tr>
            <td>num</td>
            <td>String</td>
            <td>Specifies the way number of the address</td>
        </tr>
        <tr>
            <td>wayType</td>
            <td>String</td>
            <td>Specifies the type of the way</td>
        </tr>
        <tr>
            <td>way</td>
            <td>String</td>
            <td>Specifies the name of the street/way</td>
        </tr>
        <tr>
            <td>addr</td>
            <td>String</td>
            <td>Specifies address complement</td>
        </tr>
        <tr>
            <td>floor</td>
            <td>String</td>
            <td>Specifies the floor number of the address</td>
        </tr>
        <tr>
            <td>building</td>
            <td>String</td>
            <td>Specifies the building’s identifier of the address</td>
        </tr>
        <tr>
            <td>zip</td>
            <td>String</td>
            <td>Specifies a zip code for the location</td>
        </tr>
        <tr>
            <td>city</td>
            <td>String</td>
            <td>Specifies a city</td>
        </tr>
        <tr>
            <td>countryCode</td>
            <td>String</td>
            <td>Specifies a country code</td>
        </tr>
    </tbody>
</table>

## hGeo
* Describe the exact longitude and latitude of a location

### Expected attributes of a hGeo :

<table>
    <thead>
        <tr>
            <th>Property</th>
            <th>Type</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>lat</td>
            <td>Number</td>
            <td>Specifies the exact latitude of the location</td>
        </tr>
        <tr>
            <td>lng</td>
            <td>Number</td>
            <td>Specifies the exact longitude of the location</td>
        </tr>
    </tbody>
</table>

## hHeader
* A Header object attached another structure. It is a key-value pair map

### Expected attributes of a hHeader :

<table>
    <thead>
        <tr>
            <th>Property</th>
            <th>Type</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>name</td>
            <td>String</td>
            <td>Specifies the name of the header, used as a key to identify it</td>
        </tr>
        <tr>
            <td>value</td>
            <td>Object</td>
            <td>Specifies the value of the header</td>
        </tr>
    </tbody>
</table>

### List of defined hHeader

<table>
    <thead>
        <tr>
            <th>Property</th>
            <th>Type</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>MAX_MSG_RETRIEVAL</td>
            <td>Int</td>
            <td>When retrieving messages from a channel with a hCommand, the default max quantity of messages to retrieve</td>
        </tr>
    </tbody>
</table>

# Filters Structure
## hCondition
* For more details about hCondition see [Filter](https://github.com/hubiquitus/hubiquitus/tree/master/docs/hFilter)

## hValue
* This structure defines a simple condition value for the available operand

### Expected attributes of a hValue :

<table>
    <thead>
        <tr>
            <th>Property</th>
            <th>Type</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>`name of the attribute`</td>
            <td>String or Object</td>
            <td>The value of the attribute to compare with</td>
        </tr>
    </tbody>
</table>

```js
Example : {priority : 2} ; {author:'urn:localhost:user1'}
```

## hArrayOfValue
* This structure defines an array of condition value for the available operand

### Expected attributes of a hArrayOfValue :

<table>
    <thead>
        <tr>
            <th>Property</th>
            <th>Type</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>`name of the attribute`</td>
            <td>Array</td>
            <td>Values of the attribute to compare with</td>
        </tr>
    </tbody>
</table>

```js
Example : {publisher : ['urn:localhost:user1', 'urn:localhost:user2']} ; {priority:[1, 2, 5]}
```

## hPos
* This structure defines an area around a specific location

### Expected attributes of a hPos :
<table>
    <thead>
        <tr>
            <th>Property</th>
            <th>Type</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>lat</td>
            <td>Number</td>
            <td>Specifies the exact latitude of the location</td>
        </tr>
        <tr>
            <td>lng</td>
            <td>Number</td>
            <td>Specifies the exact longitude of the location</td>
        </tr>
        <tr>
            <td>radius</td>
            <td>Int</td>
            <td>The radius expressed in meter</td>
        </tr>
    </tbody>
</table>