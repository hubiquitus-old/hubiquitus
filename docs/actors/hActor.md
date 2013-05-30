## About the hActor

The hActor is the basic actor of a Hubiquitus project.
His purpose is not to be used directly in a system but to be extended.
It provides all the basics variables and methods an Hubiquitus actor need to send/receive/treat a message

## Topology

Every actor need a topology to run. This topology describes every actor's attribute :
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
            <td>The URN of the actor. Used to identify the actor in the system</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>ip</td>
            <td>String</td>
            <td>It contains the IP of the actor</td>
            <td>No</td>
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
            <td>The method used to create the actor.<br/>
                Possible values :
                <ul>
                    <li>"inproc" : The actor will be created in the same process</li>
                    <li>"fork" : The actor will be created in a new process</li>
                </ul>
                <em>Default value : inproc</em>
            </td>
            <td>No</td>
        </tr>
        <tr>
            <td>trackers</td>
            <td>Array of Object</td>
            <td>List the properties of all the hTracker of the system.<br/>
                They are inherited from the parent of the actor.
                <em>Note that every system needs at least one tracker
            </td>
            <td>Yes</td>
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
            <td>List of adapters used by the actor to communicate. <br/>
                <em>For more details see <a href="https://github.com/hubiquitus/hubiquitus/blob/master/docs/adapters/hAdapters.md">hAdapter</a></em>
            </td>
            <td>No</td>
        </tr>
        <tr>
            <td>sharedProperties</td>
            <td>Object</td>
            <td>The properties of the actor which are commons with all his children<br/>
                If the child has the same properties, the child one override the shared one
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

Tracker's attributes :
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
            <td>trackerId</td>
            <td>String</td>
            <td>URN of the hTracker</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>trackerUrl</td>
            <td>String</td>
            <td>The url use to communicate with the hTracker</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>trackerChannel</td>
            <td>String</td>
            <td>URN of the hTracker's channel</td>
            <td>Yes</td>
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
            <td>The log level used by the actor. Possibles values :
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
    "trackers": [
        {
            "trackerId": "urn:localhost:myTracker",
            "trackerUrl": "tcp://127.0.1:1212",
            "trackerChannel": "urn:localhost:trackChannel"
        }
    ],
    "properties": { "actorProps": "value" }
}
```

## API documentation

If you want to go deeper in Hubiquitus actor, see the complete [API documentation](http://coffeedoc.info/github/hubiquitus/hubiquitus/master/) which describe class variables and methods
