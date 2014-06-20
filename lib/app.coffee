express = require 'express'
app = express()
config = require 'config'
log4js = require 'log4js'
session = require 'express-session'
request = require 'request'
(->
  log4js.setGlobalLogLevel config.logLevel.all
  #console.log 'config.logLevel', config.logLevel

  getLogger = log4js.getLogger
  log4js.getLogger = (name)->
    logger = getLogger.apply log4js, [name]
    level = config.logLevel[name] or config.logLevel.all
    level = config.logLevel.all if !level or level is '^'
    logger.setLevel level
    return logger
)()

app.use session({ secret: 'example' })

getMe = (token, cb)->
  headers = {
    Authorization: "#{token.token_type} #{ token.access_token }"
  }
  request.get {
    uri: [config.tinizen.base, config.tinizen.get_me].join '/'
    json: true
    headers,
  }, (err, resp, body) ->
    return cb err if err?
    return cb null, false if resp.statusCode isnt 200 or !body.account
    cb null, body

app.use (req, res, next)->
  unless req.session.token
    res.locals.user = req.user = 'guess'
    next()
    return

  getMe req.session.token, (err, me)->
    return next err if err?
    res.locals.user = req.user = me
    next()

app.get '/login-redirect', (req, res)->
  dialogAuthorizeURL = "#{config.tinizen.base}#{config.tinizen.dialog_authorize_uri}?\
    response_type=code&redirect_uri=#{encodeURIComponent config.client.redirect_uri}&scope=email&client_id=#{config.client.id}"
  res.render 'login-redirect', {dialogAuthorizeURL}

## routing
app.use "/tinizen", require './routes/tinizen'

logger = log4js.getLogger 'app'

app.get '/', (req, res)->
  dialogAuthorizeURL = "#{config.tinizen.base}#{config.tinizen.dialog_authorize_uri}?\
      response_type=code&redirect_uri=#{encodeURIComponent config.client.redirect_uri}&scope=email&client_id=#{config.client.id}"

  res.render 'index', {
    dialogAuthorizeURL
    user: req.user
  }

app.post '/logout', (req, res)->
  req.session.destroy()
  res.redirect '/'

## app settings
app.set 'port', config.http.port
app.set 'view engine', 'jade'
app.set 'views', __dirname + '/views'
#app.set 'view cache', false


## Test send email

client =
  key: "b746fb42c0f8a131a16362abb41a7d38"
  secret: "88700033cded7e97dd3b8a40e2af0398"

Mailjet = require 'mailjet-sendemail'

mailjet = new Mailjet(client.key, client.secret);


#sendText(from, to, subject, text)

sendText("no-reply@tinizen.com",
['huy.mai@tiniplanet.com', 'thanhhuy89vn@gmail.com'],
'This is a test !',
'Well, this is working !')

###client =
  key: "b746fb42c0f8a131a16362abb41a7d38"
  secret: "88700033cded7e97dd3b8a40e2af0398"

option =
  secure: false, ## When true uses https when false it uses http, default is true
  output: 'json' ## The output type you prefer, default is json, you can choose between php, json, xml, serialize, html, csv
instance = new Mailjet client.key, client.secret, option
debugger;


instance.sendRequest 'userDomainadd', {domain: "119.81.102.100"}, 'POST', (err, status, data, headers) ->
  console.log 'Error: ', err
  console.log 'Status: ', status
  console.log 'Data: ', data
  console.log 'Headers: ', headers###

noop = ()->
module.exports = {
  app
  start: (cb = noop)->
    @port = @app.get 'port'
    @env = @app.get 'env'

    @http = @app.listen @port
    logger.info "application start listening on port: #{@port} - mode #{@env}"
    logger.info "tinizen_host: #{config.tinizen.base}"
    cb null

  stop: (cb = noop)->
    @port = null
    @env = null
    @http.close()
    @http = null
    logger.info "application stopped"
    cb null
}
