## About the hChannel actor

The hChannel actor is our publish/subscribe actor
His purpose is to allow multi-cast message transfers.


## Topology

The hChannel actor, like all actors, extends our hActor class so he has the same topology's attributes.
But he always has specifics properties :
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
            <td>listenOn</td>
            <td>String</td>
            <td>
                URL of the publish inbound adapter <br/>
                <em>If you don't add a url, it will be automatically set</em>
            </td>
            <td>No (auto-fill)</td>
        </tr>
        <tr>
            <td>broadcastOn</td>
            <td>String</td>
            <td>
                URL of the multi-cast outbound adapter <br/>
                <em>If you don't add a url, it will be automatically set</em>
            </td>
            <td>No</td>
        </tr>
        <tr>
            <td>subscibers</td>
            <td>Array of String</td>
            <td>
                List of all URN which can subscribe to the channel. <br/>
                If the array is empty, every actor can subscribe to the channel. <br/>
                <em>Default value : [ ]</em>
            </td>
            <td>No</td>
        </tr>
        <tr>
            <td>db</td>
            <td>Object</td>
            <td>Properties of the database</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>collection</td>
            <td>String</td>
            <td>Collection of the hChannel in MongoDB</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>

Database properties :
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
            <td>host</td>
            <td>String</td>
            <td>
                The host of the mongoDB server <br/>
                <em>Default value : localhost</em>
            </td>
            <td>No</td>
        </tr>
        <tr>
            <td>port</td>
            <td>Integer</td>
            <td>
                The port of the mongoDB server <br/>
                <em>Default value : 27017</em>
            </td>
            <td>No</td>
        </tr>
        <tr>
            <td>name</td>
            <td>String</td>
            <td>The name of the database you want you to connect to</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>

Examples :

* Minimum topology :

```json
{
    "actor": "urn:localhost:myChannel",
    "type": "hchannel",
    "properties": {
        "listenOn": "tcp://127.0.0.1",
        "broadcastOn": "tcp://127.0.0.1",
        "subscribers": [],
        "db":{
            "name": "myDB"
        },
        "collection": "myChannel"
    }
}
```
* Complete topology :

```json
{
    "actor": "urn:domain:myChannel",
    "type": "myChannel",
    "method": "inproc",
    "log": {
        "logLevel": "info",
        "logFile": "./myLogFile.log"
    },
    "properties": {
        "listenOn": "tcp://127.0.0.1",
        "broadcastOn": "tcp://127.0.0.1",
        "subscribers": [],
        "db":{
            "host": "localhost",
            "port": 27017,
            "name": "myDB"
        },
        "collection": "myChannel"
    }
}
```

## API documentation

If you want to go deeper in Hubiquitus hChannel, see the complete [API documentation](http://coffeedoc.info/github/hubiquitus/hubiquitus/master/) which describe class variables and methods

