process.env.NODE_ENV = 'test' unless process.env.NODE_ENV?
sendhal = require '../lib/sendhal'
should = require 'should'

describe 'sendhal functions', ->
  req = null
  res = null

  beforeEach ->
    req = {}
    req =
      originalUrl: '/api/'
    res = {}
    res =
      send: (strContent) ->
        strContent
      redirect: (strContent) ->
        strContent
    return

  it '"ok" should set status and create hal renderer', (done) ->
    deepCoverage = false
    res.status = (code) -> code.should.eql 200
    res.format = (obj) ->
      deepCoverage = true
      obj.should.have.keys 'html', 'xml', 'json'
      obj.html().should.eql '/hal-browser/browser.html#/api/'
      obj.xml().should.eql '<resource href="/api/"></resource>'
      obj.json().should.match { _links: { self: { href: '/api/' } } }

    sendhal.ok {}, req, res
    deepCoverage.should.be.true
    done()

  it '"created" should set status code and response without body', (done) ->
    res.status = (code) -> code.should.eql 201
    req.path = '/api/'
    res.send = (body) -> body.should.be.empty
    res.location = (uri) -> uri.should.eql '/api/1f00'

    sendhal.created '1f00', req, res
    done()

  it '"notFound" should set status code and response without body', (done) ->
    res.status = (code) -> code.should.eql 201
    req.path = '/api/'
    res.send = (body) -> body.should.be.empty
    res.location = (uri) -> uri.should.eql '/api/1f00'

    sendhal.created '1f00', req, res
    done()

  it 'should handle fail call with unknown error parameter', (done) ->
    deepCoverage = false
    res.statusCode = 200
    res.status = (code) ->
      code.should.eql 500
      res.statusCode = code
    res.format = (obj) ->
      deepCoverage = true
      obj.should.have.keys 'html', 'xml', 'json'
      obj.html().should.eql '/hal-browser/browser.html#/api/'
      obj.xml().should
        .containEql '<message>unknown error type:'
        .and.containEql '<status>500'
      obj.json().should
        .have.properties
          'message': 'unknown error type: [object Object]'
          'status': 500

    sendhal.fail {}, req, res
    deepCoverage.should.be.true
    done()

  it 'should handle fail call with error object parameter', (done) ->
    deepCoverage = false
    res.statusCode = 403
    res.status = (code) -> code.should.eql 403
    res.format = (obj) ->
      deepCoverage = true
      obj.should.have.keys 'html', 'xml', 'json'
      obj.html().should.eql '/hal-browser/browser.html#/api/'
      obj.xml().should
        .containEql '<message>wabuum'
        .and.containEql '<status>403'
        .and.match /<stack>\w+/
      obj.json().should
        .have.properties
          'message': 'wabuum'
          'status': 403

    sendhal.fail new Error('wabuum'), req, res
    deepCoverage.should.be.true
    done()

  it 'should handle fail call with error Array parameter', (done) ->
    deepCoverage = false
    res.statusCode = 403
    res.status = (code) -> code.should.eql 400
    res.format = (obj) ->
      deepCoverage = true
      obj.should.have.keys 'html', 'xml', 'json'
      obj.html().should.eql '/hal-browser/browser.html#/api/'
      obj.xml().should
        .containEql '<message>errors'
        .and.containEql '<status>403'
        .and.match /<resource rel="error"><msg>test/
        .and.match /<resource rel="error"><msg>wabuum/
      obj.json().should
        .have.properties
          'message': 'errors'
          'status': 403

    sendhal.fail [new Error('wabuum'), {msg: 'test'}], req, res
    deepCoverage.should.be.true
    done()

  it 'should rewrite the default html renderer uri', (done) ->
    deepCoverage = false
    res.halredirect = '/myVeryOwn'
    res.status = (code) -> code.should.eql 200
    res.format = (obj) ->
      deepCoverage = true
      obj.html().should.eql '/myVeryOwn/api/'

    sendhal.ok {}, req, res
    deepCoverage.should.be.true
    done()