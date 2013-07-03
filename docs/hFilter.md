A filter is a JSON structure used to decide if a hMessage must be delivered or ignored.
This structure is a hCondition which describe when a hMessage is correct or not.

## How set a filter
There are few ways to put a filter :
* You can add a filter attribut in your actor topology before starting it

```js
{
    actor : 'urn:localhost:user1',
    type : 'hactor',
    filter : {} // The filter you want to apply
    properties : {}
}
```

> For more information about actor topology see [hActor](https://github.com/hubiquitus/hubiquitus/tree/master/docs/actors/hActor.md)

* You can call the setFilter function of hActor if it is already started

```js
hActor.setFilter(hCondition, callback)
```

> For more information about hActor functions see [hActor](https://github.com/hubiquitus/hubiquitus/tree/master/docs/actors/hActor.md)

* If you are connected to Hubiquitus with a hAPI, you can send a hCommand hSetFilter

##### Expected payload of type hCommand to use hSetFilter for putting a filter

```js
{
    cmd : 'hSetFilter',
    params : {} // The filter you want to apply
}
```

> For more information see the documentation of the hAPI you are using

## When a filter occurs

* When any actors receive an incoming hMessage, before doing any treatment, he checks if the hMessage passes his filter. If it passes, the hMessage will be treated; if it is not, the hMessage will be ignored.


## hCondition

A [hCondition](https://github.com/hubiquitus/hubiquitus/tree/master/docs/DataStructure.md) is an object starting with an operand among `eq, ne, gt, gte, lt, lte, in, nin, and, or, nor, relevant, geo, boolean, domain`.
Then the structure depends of the operand

### Operand "eq" - "ne" - "gt" - "gte" - "lt" - "lte"

Each operand attribute is an hValue which describes the name of an attribute and his value :

```js
{
    eq : { priority : 2 }
} // The priority of the hMessage must equal 2

{
    eq : { priority : 2, timeout : 1000 }
} // The priority of the hMessage must equal 2 AND the timeout must equal 1000

{
    gt : { priority : 1 },
    lt : { priority : 4 }
} // The priority of the hMessage must be greater than 1 AND lower than 4

{
    gt : { location.pos.lat : 20 },
    lt : { location.pos.lat : 40
} // The location of the hMessage must have a latitude between 20 and 40
```

### Operand "in" - "nin"

Each operand attribute is an hArrayOfValue which describes the name of an attribute and an array of their value :

```js
{
    in : { publisher : ['urn:localhost:user1', 'urn:localhost:user2'] }
} // The publisher of the hMessage must be urn:localhost:user1 or urn:localhost:user2

{
    in : { publisher : ['urn:localhost:user1', 'urn:localhost:user2'], author : ['urn:localhost:user1', 'urn:localhost:user2'] }
} // The publisher of the hMessage must be urn:localhost:user1 or urn:localhost:user2 AND the author of the hMessage must be urn:localhost:user1 or urn:localhost:user2

{
    in : { publisher : ['urn:localhost:user1', 'urn:localhost:user2'] },
    nin : { author : ['urn:localhost:user3', 'urn:localhost:user4'] }
} // The publisher of the hMessage must be urn:localhost:user1 or urn:localhost:user2 AND the author of the hMessage must not be urn:localhost:user3 or urn:localhost:user4

{
    eq : { type : 'hCommand' },
    in : { payload.cmd : ['hSubscribe', 'hUnsubscribe'] }
} // The type of the hMessage must be hCommand AND the cmd attribute of the payload must be hSubscribe or hUnsubscribe
```

### Operand "and" - "or" - "nor"

Each operand attribute is an Array which contains at least 2 hCondition :

```js
{
    and : [
           {eq : { priority : 2 }},
           {in : { publisher : ['urn:localhost:user1', 'urn:localhost:user2'] }}
          ]
} // The priority of the hMessage must equal 2 AND The publisher of the hMessage must be urn:localhost:user1 or urn:localhost:user2

{
    or : [
          {eq : { priority : 2 }},
          {in : { publisher : ['urn:localhost:user1', 'urn:localhost:user2'] }}
         ]
} // The priority of the hMessage must equal 2 OR The publisher of the hMessage must be user1@domain or user2@domain

{
    nor : [
           {eq : { priority : 2 }},
           {in : { publisher : ['urn:localhost:user1', 'urn:localhost:user2'] }}
          ]
} // The priority of the hMessage must not equal 2 AND The publisher of the hMessage must not be user1@domain or user2@domain
```

### Operand "not"

Each operand attribute is a hCondition :

```js
{
    not : { eq : { priority : 2 } }
} // The priority of the hMessage must not equal 2

{
    not : {
           eq : { priority : 2 },
           in : { publisher : ['urn:localhost:user1', 'urn:localhost:user2'] }
          }
} // The priority of the hMessage must not equal 2 OR The publisher of the hMessage must not be user1@domain or user2@domain
```

### Operand "relevant" - "boolean"

Each operand attribute is a boolean :

```js
{
    relevant: true
} // The hMessage must be relevant

{
    relevant: false
} // The hMessage must not be relevant

{
    boolean: false
} // Any hMessage will be rejected

{
    boolean: true
} // Any hMessage will be accepted (like an empty filter : {})
```

### Operand "geo"

Each operand attribute is a hPos :

```js
{
    geo: {
          lat: 48,
          lng: 2,
          radius: 10000
         }
} // The position of the hMessage must be 10 000m around this point(lat/lng)
```

### Operand "domain"

Each operand attribute is a string :

```js
{
    domain: 'myproject.domain.com'
} // The domain of the hMessage's publisher must be 'myproject.domain.com'

{
    domain: '$mydomain'
} // The domain of the hMessage's publisher must be the same as mine
```