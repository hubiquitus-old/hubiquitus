## About the couchbase_out Adapter

The couchbase_out adapter is an adapter which allow to store hMessages in database by using a channel.

## Topology

You can add a couchbase_out adapter to your channel by completing the specifics attributes in your channel topology.

```json
{
    "actor": "urn:localhost:myChannel",
    "type": "hchannel",
    "method": "inproc",
    "properties": {
        "subscribers": [],
        "persistentAid": "urn:localhost:couchbase"
    },
    "adapters": [{
        "type": "couchbase_out",
        "targetActorAid": "urn:localhost:couchbase",
        "properties": {
            "user": "root",
            "password": "hubiquitus",
            "bucket": "myBucket"
        }
    }]
}
```
Add a property <b>"persistentAid": "urn:localhost:couchbase"</b> on your channel as in the previous topology.

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
        <td>Value : <em>urn:localhost:couchbase</em></td>
        <td>Yes</td>
    </tr>
    <tr>
        <td>type</td>
        <td>String</td>
        <td>Value : <em>couchbase_out</em></td>
        <td>Yes</td>
    </tr>
    <tr>
        <td>properties</td>
        <td>object</td>
        <td>
            The properties of the couchbase_out adapter, depending on your couchbase installation
        </td>
        <td>Yes</td>
    </tr>
    </tbody>
</table>

* couchbase_out properties :

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
        <td>debug</td>
        <td>String</td>
        <td>Default : <em>false</em></td>
        <td>No</td>
    </tr>
    <tr>
        <td>user</td>
        <td>String</td>
        <td>Default : <em>Administrator</em></td>
        <td>No</td>
    </tr>
    <tr>
        <td>password</td>
        <td>String</td>
        <td>Default : <em>password</em></td>
        <td>No</td>
    </tr>
    <tr>
        <td>hosts</td>
        <td>String</td>
        <td>Default : <em>[ "localhost:8091" ]</em></td>
        <td>No</td>
    </tr>
    <tr>
        <td>bucket</td>
        <td>String</td>
        <td>Default : <em>default</em></td>
        <td>No</td>
    </tr>
    </tbody>
</table>

## API documentation

If you want to go deeper in Hubiquitus couchbase_out Adapter, see the complete [API documentation](http://coffeedoc.info/github/hubiquitus/hubiquitus/master/) which describe class variables and methods


        

