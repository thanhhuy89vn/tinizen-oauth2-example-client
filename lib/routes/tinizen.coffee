  express = require 'express'
request = require 'request'
oauth2 = module.exports = express.Router()
config = require 'config'

errors =
  'access_denied':
    code: 401
    message: 'You didn\'t approve this example to access your data'
  'invalid_credentials':
    code: 401
    message: 'Invalid grant code or client credentials'

getError = (err)->
  error = errors[err]
  return error or {
    code: 400
    message: 'Unknown Error'
  }

oauth2.get '/callback', (req, res) ->

  grantCode = req.query.code
  error = req.query.error

  error = getError error if error or !grantCode

  return res.render 'login_failed', {error} if error


  ## Make request to tinizen get
  request.post {
    uri: config.tinizen.base + config.tinizen.token_uri
    json: true
    body:
      grant_type: 'authorization_code'
      code: grantCode
      redirect_uri: config.client.redirect_uri
      client_id: config.client.id
      client_secret: config.client.secret
  }, (err, resp, body)->
    return res.render 'login_failed', getError err if err?
    return res.render 'login_failed', getError 'invalid_credentials' if resp.statusCode isnt 200
    req.session.token =
      token_type : 'Bearer'
      access_token: body.access_token

    res.render "login_success"

