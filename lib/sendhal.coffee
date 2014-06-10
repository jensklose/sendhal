hal = require 'hal'

send = (renderer, req, res) ->
  accepted =
    html: ->
      halBrowserUri = res.halredirect or '/hal-browser/browser.html#'
      res.redirect halBrowserUri + req.originalUrl
    xml:  -> res.send renderer.toXML()
    json: -> res.send renderer.toJSON()

  res.format accepted

sendhal =
  ok: (doc, req, res) ->
    res.status res.statusCode or 200
    renderer = new hal.Resource doc, req.originalUrl
    send renderer, req, res

  created: (id, req, res) ->
    res.location (req.path.replace /\/+$/, '') + '/' + id
    res.status 201
    res.send ''

  fail: (err, req, res, next) ->
    next = ->
    appError = {}
    embedded = []
    errType = Object.prototype.toString.call(err)
    switch errType
      when '[object Array]'
        res.status 400
        appError.message = 'errors'
        errorMap = (item) ->
          embedded.push(
            ({msg: item.message} if ('[object Error]' is Object.prototype.toString.call(item))) or item
          )
        errorMap item for item in err

      when '[object Error]'
        isErrorStatus = res.statusCode >= 400
        errorStatus = err.status or (res.statusCode if isErrorStatus) or 500
        res.status errorStatus
        appError.message = err.message
        if process.env.NODE_ENV is 'development' or 'test'
          appError.stack = err.stack

      else
        res.status res.statusCode or 500
        appError.message = 'unknown error type: ' + errType
        appError.stack = err

    appError.status = res.statusCode
    renderer = hal.Resource appError, req.originalUrl
    if embedded
      renderer.embed('errors', row) for row in embedded

    send renderer, req, res

module.exports = sendhal
module.exports.hal = hal
module.exports.Resource = hal.Resource