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
                    <li>hChannel</li>
                    <li>hTracker</li>
                    <li>hGateway</li>
                    <li>hAuth</li>
                    <li>hSession</li>
                    <li>hDispatcher</li>
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
            <td>ressource</td>
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
            <td>List all the actor's inbound adapter</td>
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

### onMessage

### send

### createChild

### log

### initChildren

### touchTrackers

### initialize

### preStop

### postStop

### raiseError

### closeError

### setFilter

### validateFilter

### subscribe

### unsubscribe

### getSubscriptions

### updateAdapter

### removePeer

### buildMessage

### buildCommand

### buildResult

### buildMeasure

### buildAlert

### buildAck

### buildConvState
