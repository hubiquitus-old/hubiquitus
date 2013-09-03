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

In this example the adapter attribute are :

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
        <td>Value : <em>urn:localhost:mongo</em></td>
        <td>Yes</td>
    </tr>
    <tr>
        <td>type</td>
        <td>String</td>
        <td>Value : <em>mongo_out</em></td>
        <td>Yes</td>
    </tr>
    <tr>
        <td>properties</td>
        <td>object</td>
        <td>
            The properties of the mongo_out adapter, depending on your mongo installation
        </td>
        <td>Yes</td>
    </tr>
    </tbody>
</table>

* mongo_out properties :

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
        <td>No</td>
    </tr>
    <tr>
        <td>collection</td>
        <td>String</td>
        <td>the name of the collection</td>
        <td>No</td>
    </tr>
    </tbody>
</table>

## API documentation

If you want to go deeper in Hubiquitus mongo_out Adapter, see the complete [API documentation](http://coffeedoc.info/github/hubiquitus/hubiquitus/master/) which describe class variables and methods




