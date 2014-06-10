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
var path = require('path');
var logger = require('morgan');
//var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var sendhal = require('sendhal');
var models = require('./lib/models');
// create database connection
var db = models.createDbConnection();
models.createAllIndexes(db);

var routes = require('./routes/index');
var app = express();
app.use(logger(config.loggerOptions));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded());
app.use(express.static(path.join(__dirname, 'public')));

// reuse the db connection on any request
app.use(function(req, res, next) {
    req.db = db;
    next();
});
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