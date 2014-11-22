# sendhal

[![Build Status](https://travis-ci.org/jensklose/sendhal.svg?branch=master)](https://travis-ci.org/jensklose/sendhal)

Express middleware and error handler to send hal responses with json/xml/html negotiation.

## Install
```sh
npm install sendhal --save
```

## Usage
This example shows the basic usage in an express 4 context.

```javascript
    var express = require('express');
    var config = require('config');
    var sendhal = require('sendhal');
    var app = express();
    
    app.route('/api').get(function(req, res, next) {
        var rootRelations, hal, rel, _ref;
        hal = sendhal.Resource({welcome: 'api entry'}, req.path);
        _ref = config.relations;
        for (rel in _ref) {
            rootRelations = _ref[rel];
            hal.link(rel, rootRelations);
        }
        return sendhal.ok(hal, req, res);
    });
    
    app.use('/api', function(req, res, next) {
        var err, method;
        method = req.method.toLowerCase();
        if (method === 'get') {
            err = new Error('Not Found');
            res.status(404);
            return sendhal.fail(err, req, res, next);
        }
        res.status(405);
        return sendhal.fail(new Error('Method Not Allowed'), req, res, next);
      });
    app.use('/api', sendhal.fail);
```

## API
### ok
```javascript
ok(doc, req, res)
```
send statusCode res.statusCode or 200    
the URI of ```_self``` is set by ```req.originalUrl```

*   doc: resource content
*   req: express request
*   res: express response

### created
```javascript
created(id, req, res)
```
send statusCode 201    
set header 'location:' to ```req.path + id```

- id: the new resource id
- req: express request
- res: express response

### notFound
```javascript
notFound(req, res)
```
send not found response with code 404

- req: express request
- res: express response

### fail
```javascript
fail(err, req, res, next)
```
implementation of express error handler interface     
The err parameter is used to switch the output

- [object Array]: statusCode 400; used for validation errors
- [object Error]: statusCode 500; used for server errors
- any other: statusCode 500

You can set the status code with ```err.status``` or ```res.statusCode```

### Resource
```javascript
Resource(object, uri)
```
the <https://github.com/naholyr/js-hal> resource object
