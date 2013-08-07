## About the twitter_in Adapter

The twitter adapter is used to fetch twit from the twitter 1.1 API

## Topology

You can add a twitter adapter to your actor by completing the specifics attributes in your actor topology.

```json
{
    "actor": "urn:domain:myActor",
    "type": "myActor"
    "adapters": [
        {
            "type": "twitter_in",
            "properties": {
                "name": "twitter",
                "proxy": "http://hostname:port",
                "consumerKey": "supkCU9BZjUifb22xJYWw",
                "consumerSecret": "U2zbZforgtzuBD26pmG6en946VtTD237HfcK6xho",
                "twitterAccesToken": "1570147814-BK0CkD6ocLht1CdHgvxZrHhh1am3GHToWoVBQCj",
                "twitterAccesTokenSecret": "YqQnyESoiMJHgOYwO8JgdwnLCcNHmpNpuHmi5krJy4",
                tags:"",
                account:"",
                locations: ""
            }
        }
    ]
}
```

In this example the adapters attributes are :

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
            <td>type</td>
            <td>String</td>
            <td><em>Value : channel_in</em></td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>properties</td>
            <td>Object</td>
            <td>The properties of the twitter adapter.
            </td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>

* Twitter adapter properties :

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
            <td>The name of your twitter adapter (use to update)</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>proxy</td>
            <td>String</td>
            <td>The url of your proxy (if needed)</td>
            <td>No</td>
        </tr>
        <tr>
            <td>consumerKey</td>
            <td>String</td>
            <td>You twitter app consumerKey</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>consumerSecret</td>
            <td>String</td>
            <td>You twitter app consumerSecret</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>twitterAccesToken</td>
            <td>String</td>
            <td>You twitter app twitterAccesToken</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>twitterAccesTokenSecret</td>
            <td>String</td>
            <td>You twitter app twitterAccesTokenSecret</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>tags</td>
            <td>String</td>
            <td>Hashtags you want to fetch (separated by ',')</td>
            <td>No<sup>(1)</td>
        </tr>
        <tr>
            <td>accounts</td>
            <td>String</td>
            <td>Screen names or userIDs<sup>(2)</sup> you want to follow (separated by ',') <br>Screen names & userIDs can be mixed.</td>
            <td>No<sup>(1)</td>
        </tr>
        <tr>
            <td>locations</td>
            <td>String</td>
            <td>The location you want to focus on. Precise the left bottom corner and then the right up corner, lattitude, longitude. Ex : -2.5,43.3,7.2,50.6 for France (separate with ',' if you want to enter many zone)</td>
            <td>No<sup>(1)</td>
        </tr>
    </tbody>
</table>
<sup>(1)</sup> At least one of the three
<sup>(2)</sup> You can get a twitter account userID from its screen name [here](http://gettwitterid.com/).
Screen names


> To obtain the consumerKey, consumerSecret, twitterAccesToken and twitterAccesTokenSecret you need to add a new app on your twitter dev [account](https://dev.twitter.com/apps)

## API documentation

If you want to go deeper in Hubiquitus twitter Adapter, see the complete [API documentation](http://coffeedoc.info/github/hubiquitus/hubiquitus/master/) which describe class variables and methods
