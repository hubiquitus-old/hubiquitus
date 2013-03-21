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
                "consumerKey": "cMXVWvotA5c86Nc8tPhtvA",
                "consumerSecret": "VklYGUWU31Qh8ZnhAX1rt82nTkmfvey3U6rbuBxnAk",
                "twitterAccesToken": "819820982-H4lPh9e0EvsivXdfaORl1lJSdzPdCpQYfHAqclsP",
                "twitterAccesTokenSecret": "Zex6O4tEgEPIF2cE39XVcg0C5MJNxJfV7FNRqSupu0c",
                "tags":"hubiquitus"
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
            <td>The hashtag you want to fetch (separate with ',' if needed)</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>

> To obtain the consumerKey, consumerSecret, twitterAccesToken and twitterAccesTokenSecret you need to add a new app on your twitter dev [account](https://dev.twitter.com/apps)

## API documentation

If you want to go deeper in Hubiquitus twitter Adapter, see the complete [API documentation](http://coffeedoc.info/github/hubiquitus/hubiquitus/master/) which describe class variables and methods
