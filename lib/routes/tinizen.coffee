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

  ## GET HTTP: http://<your-domain>/callback

  ## tiNiZen will send to you
  ##  -  grant_code: user login success and allow permission
  ##  -  or error message: user not allow permission or unkown error

  grantCode = req.query.code
  error = req.query.error

  error = getError error if error or !grantCode

  ## If have error, your-app will show login_failed to user
  return res.render 'login_failed', {error} if error


  ## Else, your-app can exchange grant code for access token for this user.
  ## To do this, make post request to tiNiZen:
  ## - tinizen.base: tiNiZen domain, eg: http://tinizen.com
  ## - tiNiZen.tokenuri: URI to exchange grant code to get token, is oauth/token
  ## - grant_type: type of grant, is "authorization_code"
  ## - client_id: client_id of your-app
  ## - client_secret: client secret of your-app
  ## - redirect_uri: callback URI of your-app
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

    ## tiNizen responses:
    ## err: error from tiNiZen if invalid request
    ## resp: response
    ## body: access token string

    ## Note: successful responses have statusCode = 200

    ## So, you can assgin session to user request and return to "login_success"
    return res.render 'login_failed', getError err if err?
    return res.render 'login_failed', getError 'invalid_credentials' if resp.statusCode isnt 200
    req.session.token =
      token_type : 'Bearer'
      access_token: body.access_token

    res.render "login_success"

