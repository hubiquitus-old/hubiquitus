## About the hActor

The hActor is the basic actor of a Hubiquitus project.
His purpose is not to be use directly in a system but to be extend.
It provide all the basics variables and methods an Hubiquitus actor need to send/receive/treat a message

## Topology

Every actor need a topology to run. This topology describe every attributes of the actor :
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
            <td>actor</td>
            <td>String</td>
            <td>The URN of the actor. Use to identify the actor in the system</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>type</td>
            <td>String</td>
            <td>The type of the hActor. It contains the name of the implementation used for the hActor.<br/>
                Possible values :
                <ul>
                    <li>hchannel</li>
                    <li>htracker</li>
                    <li>hgateway</li>
                    <li>hauth</li>
                    <li>hsession</li>
                    <li>hdispatcher</li>
                    <li><em>Your own type of actor</em></li>
                </ul>
            </td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>method</td>
            <td>String</td>
            <td>The method use to create the actor.<br/>
                Possible values :
                <ul>
                    <li>"inproc" : The actor will be create in the same process</li>
                    <li>"fork" : The actor will be create in a new process</li>
                </ul>
                <em>Default value : inproc</em>
            </td>
            <td>No</td>
        </tr>
        <tr>
            <td>log</td>
            <td>Object</td>
            <td>Configure the logger <br/>
                <em> See logger's attributes for more details </em>
            </td>
            <td>No</td>
        </tr>
        <tr>
            <td>adapters</td>
            <td>Array of Object</td>
            <td>List of adapters use by the actor to communicate. <br/>
                <em>For more details see <a href="https://github.com/hubiquitus/hubiquitus/blob/master/docs/adapters/hAdapters.md">hAdapter</a></em>
            </td>
            <td>No</td>
        </tr>
        <tr>
            <td>sharedProperties</td>
            <td>Object</td>
            <td>The properties of the actor which are commons with all his children<br/>
                If the child have a same properties, the child one override the shared one
            </td>
            <td>No</td>
        </tr>
        <tr>
            <td>properties</td>
            <td>Object</td>
            <td>The properties of the actor which depends of the type actor.<br/>
                <em> For more details see the other Hubiquitus <a href="https://github.com/hubiquitus/hubiquitus/blob/master/docs/actors">actors</a></em>
            </td>
            <td>No</td>
        </tr>
        <tr>
            <td>children</td>
            <td>Array of Object</td>
            <td>List of children the actor will create.
                This list must contains actor's topology of every child.
            </td>
            <td>No</td>
        </tr>
    </tbody>
</table>

Logger's attributes :

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
            <td>logLevel</td>
            <td>String</td>
            <td>The log level use by the actor. Possibles values :
                <ul>
                    <li>"error" : display only error logs</li>
                    <li>"warn" : display error and warn logs</li>
                    <li>"info" : display error, warn and info logs</li>
                    <li>"debug" : display all logs</li>
                </ul>
                <em> Default value : info </em>
            </td>
            <td>No</td>
        </tr>
        <tr>
            <td>logFile</td>
            <td>String</td>
            <td>Path to a logFile where you want to save the logs<br/>
                <em> Default value : none </em>
            </td>
            <td>No</td>
        </tr>
    </tbody>
</table>


Examples :

* Minimum topology :

```json
{
    "actor": "urn:domain:myActor",
    "type": "myActor"
}
```
* Complete topology :

```json
{
    "actor": "urn:domain:myActor",
    "type": "myActor",
    "method": "fork",
    "log": {
        "logLevel": "info",
        "logFile": "./myLogFile.log"
    },
    "adapters": [ {"type": "socket_in", "url": "tcp://127.0.0.1:1212"} ],
    "children": [
        {
            "actor": "urn:domain:myChild",
            "type": "myActor"
        }
    ],
    "properties": { "actorProps": "value" }
}
```

## Class variables

When you start an actor you have access to some class variables :
<table>
    <thead>
        <tr>
            <th>Property</th>
            <th>Type</th>
            <th>Description</th>
            <th>default Value</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>log_properties</td>
            <td>Object</td>
            <td>Contains the log properties object. It will be transfer to every children</td>
            <td>undefined</td>
        </tr>
        <tr>
            <td>logger</td>
            <td>Object</td>
            <td>The instance of the logger use to display logs</td>
            <td>n/a</td>
        </tr>
        <tr>
            <td>actor</td>
            <td>String</td>
            <td>Actor's ID in URN format (with resource)</td>
            <td>n/a</td>
        </tr>
        <tr>
            <td>resource</td>
            <td>String</td>
            <td>Resource of the actor's URN</td>
            <td>n/a</td>
        </tr>
        <tr>
            <td>type</td>
            <td>String</td>
            <td>Type of the hActor</td>
            <td>n/a</td>
        </tr>
        <tr>
            <td>filter</td>
            <td><a href="https://github.com/hubiquitus/hubiquitus/tree/master/docs/hFilter">hCondition</a></td>
            <td>The filter to use on incoming message</td>
            <td>{ }</td>
        </tr>
        <tr>
            <td>msgToBeAnswered</td>
            <td>Object</td>
            <td>Contains the callback to call on incoming hResult</td>
            <td>{ }</td>
        </tr>
        <tr>
            <td>timerOutAdapter</td>
            <td>Object</td>
            <td>Contains the timeout launch to forget an outbound adapter if it not use</td>
            <td>{ }</td>
        </tr>
        <tr>
            <td>error</td>
            <td>Object</td>
            <td>Contains the id and message of actor's errors</td>
            <td>{ }</td>
        </tr>
        <tr>
            <td>timerTouch</td>
            <td>Object</td>
            <td>Interval set between 2 touchTrackers</td>
            <td>undefined</td>
        </tr>
        <tr>
            <td>parent</td>
            <td>Actor</td>
            <td>The actor which create this actor</td>
            <td>undefined</td>
        </tr>
        <tr>
            <td>touchDelay</td>
            <td>number</td>
            <td>Delay between 2 touchTrackers<br/>
                <em>Don't change this value</em>
            </td>
            <td>60000</td>
        </tr>
        <tr>
            <td>sharedProperties</td>
            <td>Object</td>
            <td>Properties shared between an actor and his children</td>
            <td>{ }</td>
        </tr>
        <tr>
            <td>properties</td>
            <td>Object</td>
            <td>Properties of the actor</td>
            <td>{ }</td>
        </tr>
        <tr>
            <td>status</td>
            <td>String</td>
            <td>State of the actor</td>
            <td>"stopped"</td>
        </tr>
        <tr>
            <td>children</td>
            <td>Array</td>
            <td>List of topology of the actor's children</td>
            <td>[ ]</td>
        </tr>
        <tr>
            <td>trackers</td>
            <td>Array</td>
            <td>Properties of the trackers which watch the actor</td>
            <td>[ ]</td>
        </tr>
        <tr>
            <td>inboundAdapters</td>
            <td>Array</td>
            <td>List all the actor's inbound adapter</td>
            <td>[ ]</td>
        </tr>
        <tr>
            <td>outboundAdapters</td>
            <td>Array</td>
            <td>List all the actor's outbound adapter</td>
            <td>[ ]</td>
        </tr>
        <tr>
            <td>subscriptions</td>
            <td>Array</td>
            <td>List all the channel that the actor has subscribed</td>
            <td>[ ]</td>
        </tr>
        <tr>
            <td>channelToSubscribe</td>
            <td>Array</td>
            <td>List all subscribe command the actor have to launch after start</td>
            <td>[ ]</td>
        </tr>

    </tbody>
</table>


## Methods

### onMessage (hMessage)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>hMessage</td>
            <td>Object</td>
            <td>The incoming hMessage, receive by the actor</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>
This method is called when an actor receive an incoming message.
By default this method has no effect. You need to override it in your actor.

### send (hMessage, cb)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>hMessage</td>
            <td>Object  </td>
            <td>The incoming hMessage, receive by the actor</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>cb</td>
            <td>Function</td>
            <td>The function to call when an answer is receive</td>
            <td>No</td>
        </tr>
    </tbody>
</table>
This method must be call when you want to send a hMessage to another actor.
It will check for an outboundAdapter and ask to the tracker if needed.
If you use the `cb` parameter, the send function will call your callback function when it receive the answer of the send message.

### createChild (classname, method, topology, cb)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>classname</td>
            <td>String</td>
            <td>The type of the hActor. It contains the name of the implementation used for the hActor.<br/>
                Possible values :
                <ul>
                    <li>hchannel</li>
                    <li>htracker</li>
                    <li>hgateway</li>
                    <li>hauth</li>
                    <li>hsession</li>
                    <li>hdispatcher</li>
                    <li><em>Your own type of actor</em></li>
                </ul>
            </td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>method</td>
            <td>String</td>
            <td>The method use to create the actor.<br/>
                Possible values :
                <ul>
                    <li>"inproc" : The actor will be create in the same process</li>
                    <li>"fork" : The actor will be create in a new process</li>
                </ul>
            </td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>topology</td>
            <td>Object</td>
            <td>The topology of the actor which will be create</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>cb</td>
            <td>Function</td>
            <td>A function call when the actor is create. It return the child instance as parameters</td>
            <td>No</td>
        </tr>
    </tbody>
</table>
This method is used to create and start a child actor.

### log (type, message)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>type</td>
            <td>String</td>
            <td>The log level of the message</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>message</td>
            <td>String</td>
            <td>The log message</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>
This method enrich a message with actor details and logs it in the console and/or in a log file

### initChildren (children)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>children</td>
            <td>Array of Object</td>
            <td>Array containing the topology of the actor's children</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>
This Method is called by the constructor to initializing actor's children

### initialize (done)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>done</td>
            <td>Function</td>
            <td>Callback use when the initialization is done</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>
This method is called after starting an actor.
You have to override it if you need a specific initialization before considering your actor ready.

### preStop (done)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>done</td>
            <td>Function</td>
            <td>Callback use when the preStop is done</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>
This method is called before stopping an actor.
You have to override it if you need specifics treatments before stopping the actor.

### postStop (done)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>done</td>
            <td>Function</td>
            <td>Callback use when the postStop is done</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>
This method is called after stopping an actor.
You have to override it if you need specifics treatments after stopping the actor.

### raiseError (id, message)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>id</td>
            <td>String</td>
            <td>The identifier of an error <em>(must be unique)</em></td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>message</td>
            <td>String</td>
            <td>The message which describe the error to raise</td>
            <td>No</td>
        </tr>
    </tbody>
</table>
You can call this method if your actor is in error and it don't be able to treat message.
Your actor status become `error` and he receive only message specifically send to him (with fullURN)


### closeError (id)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>id</td>
            <td>String</td>
            <td>The identifier of the error to close</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>
You can call this method when an error previously rise is ended.
It will close the error and update the actor status to `ready` if they don't have other error rise

### setFilter (hCondition, cb)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>hCondition</td>
            <td>Object</td>
            <td>The hMessage checked with the actor's filter</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>cb</td>
            <td>Function</td>
            <td>The callback called after setting the filter</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>
This method is used when you want to set a filter on an actor.
A filter must have the [hCondition](https://github.com/hubiquitus/hubiquitus/blob/master/docs/DataStructure.md) structure.

### validateFilter (hMessage)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>hMessage</td>
            <td>Object</td>
            <td>The hMessage checked with the actor's filter</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>
This method is called on incoming message to check if the hMessage respect the actor's filter

### subscribe (hChannel, quickFilter, cb)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>hChannel</td>
            <td>String</td>
            <td>The URN of the channel the actor will subscribe</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>quickFilter</td>
            <td>String</td>
            <td>With a quickFilter you will receive only the message compliant with this quickFilter (like a topic)</td>
            <td>No</td>
        </tr>
        <tr>
            <td>cb</td>
            <td>Function</td>
            <td>The callback called after setting the filter</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>
This method is called to subscribe to a channel
If a quickFilter is specified, the method subscribe the actor just for this quickFilter (like his subscribe to a topic)

### unsubscribe (hChannel, quickFilter, cb)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>hChannel</td>
            <td>String</td>
            <td>The URN of the channel the actor will unsubscribe</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>quickFilter</td>
            <td>String</td>
            <td>With a quickFilter you will be unsubscribe only of the message compliant with this quickFilter (like a topic)</td>
            <td>No</td>
        </tr>
        <tr>
            <td>cb</td>
            <td>Function</td>
            <td>The callback called after setting the filter</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>
This method is called to unsubscribe to a channel
If a quickFilter is specified, the method unsubscribe the actor just for this quickFilter (like his subscribe to a topic).

### getSubscriptions ()
This method is called to get the actor subscription.
It return an array of string containing the URN of the subscribe channel

### updateAdapter (name, properties)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>name</td>
            <td>String</td>
            <td>The name of the adapter you want to update</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>properties</td>
            <td>Object</td>
            <td>The new properties to apply to the adapter</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>
This method is called when you want to update an adapter.
To use it, your adapter must have a `name` propertie.

### removePeer (actor)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>actor</td>
            <td>String</td>
            <td>The URN of the actor to remove</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>
This method is called to remove a actor from outboundAdapter
It automatically call when an actor don't use an outbound adapter during 90 seconds

### buildMessage (actor, type, payload, options)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>actor</td>
            <td>String</td>
            <td>URN of the target of the hMessage</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>type</td>
            <td>String</td>
            <td>Type of the hMessage</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>payload</td>
            <td>Object</td>
            <td>Content of the hMessage</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>options</td>
            <td>Object</td>
            <td>Optionals attributes of the hMessage</td>
            <td>No</td>
        </tr>
    </tbody>
</table>
You can call this method to easily build a correct hMessage

### buildCommand (actor, cmd, params, options)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>actor</td>
            <td>String</td>
            <td>URN of the target of the hMessage</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>cmd</td>
            <td>String</td>
            <td>The type of the hCommand</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>params</td>
            <td>Object</td>
            <td>The parameters of the hCommand</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>options</td>
            <td>Object</td>
            <td>Optionals attributes of the hMessage</td>
            <td>No</td>
        </tr>
    </tbody>
</table>
You can call this method to easily build a correct hMessage whit an hCommand payload

### buildResult (actor, ref, status, result, options)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>actor</td>
            <td>String</td>
            <td>URN of the target of the hMessage</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>ref</td>
            <td>String</td>
            <td>The msgid of the message refered to</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>status</td>
            <td>Integer</td>
            <td>The status of the operation</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>result</td>
            <td>Object, Array, String, Boolean, Number</td>
            <td>The result of a command operation</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>options</td>
            <td>Object</td>
            <td>Optionals attributes of the hMessage</td>
            <td>No</td>
        </tr>
    </tbody>
</table>
You can call this method to easily build a correct hMessage whit an hResult payload

### buildMeasure (actor, value, unit, options)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>actor</td>
            <td>String</td>
            <td>URN of the target of the hMessage</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>value</td>
            <td>Number</td>
            <td>The value of the measure</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>unit</td>
            <td>String</td>
            <td>The unit in which the measure is expressed</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>options</td>
            <td>Object</td>
            <td>Optionals attributes of the hMessage</td>
            <td>No</td>
        </tr>
    </tbody>
</table>
You can call this method to easily build a correct hMessage whit an hMeasure payload

### buildAlert (actor, alert, options)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>actor</td>
            <td>String</td>
            <td>URN of the target of the hMessage</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>alert</td>
            <td>String</td>
            <td>The message provided by the author to describe the alert</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>options</td>
            <td>Object</td>
            <td>Optionals attributes of the hMessage</td>
            <td>No</td>
        </tr>
    </tbody>
</table>
You can call this method to easily build a correct hMessage whit an hAlert payload

### buildAck (actor, ref, ack, options)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>actor</td>
            <td>String</td>
            <td>URN of the target of the hMessage</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>ref</td>
            <td>String</td>
            <td>The msgid of the hMessage refered to</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>ack</td>
            <td>String</td>
            <td>The status of the acknowledgement</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>options</td>
            <td>Object</td>
            <td>Optionals attributes of the hMessage</td>
            <td>No</td>
        </tr>
    </tbody>
</table>
You can call this method to easily build a correct hMessage whit an hAck payload

### buildConvState (actor, convid, status, options)
<table>
    <thead>
        <tr>
            <th>Parameters</th>
            <th width="55pt">Type</th>
            <th width="550pt">Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>actor</td>
            <td>String</td>
            <td>URN of the target of the hMessage</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>convid</td>
            <td>String</td>
            <td>Convid of the thread describe by the status</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>status</td>
            <td>String</td>
            <td>The status of the thread</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>options</td>
            <td>Object</td>
            <td>Optionals attributes of the hMessage</td>
            <td>No</td>
        </tr>
    </tbody>
</table>
You can call this method to easily build a correct hMessage whit an hConvState payload
