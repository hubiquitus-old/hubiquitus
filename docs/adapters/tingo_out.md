## About the tingo_out Adapter

The tingo_out adapter is an adapter which allow to store hMessages in database (file format) by using a channel.

## Topology

You can add a tingo_out adapter to your channel by completing the specifics attributes in your channel topology.

```json
{
    "actor": "urn:localhost:myChannel",
    "type": "hchannel",
    "method": "inproc",
    "properties": {
        "subscribers": [],
        "persistentAid": "urn:localhost:tingo"
    },
    "adapters": [{
        "type": "tingo_out",
        "targetActorAid": "urn:localhost:tingo",
        "properties": {
            "path": "your/path/",
            "collection": "Newcollection"
        }
    }]
}
```
Add a property <b>"persistentAid": "urn:localhost:tingo"</b> on your channel as in the previous topology.

tingo_out adapter properties are :

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
        <td>Urn of the adapter. Any message send by the actor to this address will be stored in tingo</td>
        <td>Yes</td>
    </tr>
    <tr>
        <td>type</td>
        <td>String</td>
        <td>tingo_out</td>
        <td>Yes</td>
    </tr>
    <tr>
        <td>properties</td>
        <td>object</td>
        <td>
            Properties to connect to the tingo database
        </td>
        <td>Yes</td>
    </tr>
    </tbody>
</table>

Tingo database properties :

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
        <td>path</td>
        <td>String</td>
        <td>the path of the db</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>collection</td>
        <td>String</td>
        <td>the name of the collection</td>
        <td>yes</td>
    </tr>
    </tbody>
</table>

## API documentation

If you want to go deeper in Hubiquitus tingo_out Adapter, see the complete [API documentation](http://coffeedoc.info/github/hubiquitus/hubiquitus/master/) which describe class variables and methods



