# potato-avatars

## What is it?

#### What are avatars?
Avatars are earthly creatures... whatever

Took the avatars engine from 'adorable-avatars' and made it a reusable module

## How do I use it?

```js

var avatars = require("potato-avatars").middleware;
var app = require("express")();
app.use("/avatars/:size?/:id", avatars());
```

Avatars will be available at /avatars/200/*some-user-identifier*.png


## options

### options.requestId 'params.id'

Request path notation property for user identifier (.png extension will be stripped)

### options.requestSize 'params.size'

Request path notation property for avatar size

### options.assets 'assets/'

Path to assers dir (eyes, mouth, nose)

### options.maxSize (400)

Max size for avatars

### options.minSize (40)

Min size for avatars

### options.colors ['#ffffff']

Pallete for background colors (hex)

## Open-source Contributors

* [adorableio](https://github.com/adorableio): Based on adorableio/avatars-api
* [missingdink](https://twitter.com/missingdink): Illustrated the current avatars!
