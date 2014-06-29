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
var sendhal = require('sendhal');

//...

var routes = require('./routes/index');
var app = express();

//...

app.use('/', routes);
    
/// catch 404 and forwarding to error handler
app.use(function(req, res, next) {
    var method = req.method.toLowerCase();
    if (method === 'get') {
        var err = new Error('Not Found');
        res.status(404);
        sendhal.fail(err, req, res, next);
    }
    res.status(405);
    sendhal.fail(new Error('Method Not Allowed'), req, res, next);
});

app.use(sendhal.fail);

module.exports = app;
```

./routes/index.js
```javascript
// ... 
var sendhal = require('sendhal');
// ...

router.get('/', function(req, res, next) {
    sendhal.ok({welcome: 'api root'}, req, res);
});

router.route('/transactions')
    .post(function (req, res, next) {
        // TODO: validate
        var model = new TransactionModel(req.db);
        model.insert(doc, done);
        function done(err, result) {
            if (err) {
                return sendhal.fail(err, req, res, next);
            }
            return sendhal.created(result, req, res);
        }
    })
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
