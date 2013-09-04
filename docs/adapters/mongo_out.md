## About the mongo_out Adapter

The mongo_out adapter is an adapter which allow to store hMessages in database by using a channel.

## Topology

You can add a mongo_out adapter to your channel by completing the specifics attributes in your channel topology.

```json
{
    "actor": "urn:localhost:myChannel",
    "type": "hchannel",
    "method": "inproc",
    "properties": {
        "subscribers": [],
        "persistentAid": "urn:localhost:mongo"
    },
    "adapters": [{
        "type": "mongo_out",
        "targetActorAid": "urn:localhost:mongo",
        "properties": {
            "name": "hubiquitus",
            "collection": "pubChannel"
        }
    }]
}
```
Add a property <b>"persistentAid": "urn:localhost:mongo"</b> on your channel as in the previous topology.

mongo_out adapter properties are :

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
        <td>targetActorAid</td>
        <td>String</td>
        <td>Urn of the adapter. Any message send by the actor to this address will be stored in mongo</td>
        <td>Yes</td>
    </tr>
    <tr>
        <td>type</td>
        <td>String</td>
        <td>mongo_out</td>
        <td>Yes</td>
    </tr>
    <tr>
        <td>properties</td>
        <td>object</td>
        <td>
            Properties to connect to the mongo database
        </td>
        <td>Yes</td>
    </tr>
    </tbody>
</table>

Mongo database properties :

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
        <td>name</td>
        <td>String</td>
        <td>the name of the db</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>collection</td>
        <td>String</td>
        <td>the name of the collection</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>host</td>
        <td>String</td>
        <td>mongo host</td>
        <td>No</td>
    </tr>
    <tr>
        <td>port</td>
        <td>number</td>
        <td>mongo host port</td>
        <td>No</td>
    </tr>
    <tr>
        <td>user</td>
        <td>string</td>
        <td>Mongo username if password protected</td>
        <td>No</td>
    </tr>
    <tr>
        <td>password</td>
        <td>string</td>
        <td>Mongo password if password protected</td>
        <td>No</td>
    </tr>
    </tbody>
</table>

## API documentation

If you want to go deeper in Hubiquitus mongo_out Adapter, see the complete [API documentation](http://coffeedoc.info/github/hubiquitus/hubiquitus/master/) which describe class variables and methods




