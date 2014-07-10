tinizen-oauth2-example-client
=============================



In order to integrate tiNiZen login/signup with your-app, you will first need to setup a tiNiZen application. To do this, follow the below steps:

### Some note:
- This example wrote by coffeescript
- How to run this problem:
	- Requirement your machine install: nodejs, npm, coffeescript
	- Clone this project to your machine\
    - Contact to support and give new config (tiNiZen domain, client id, client secret...)
    - Open terminal (or nodejs cmd on windows), cd to project folder, then run:
    	- npm install
        - coffeescript server.coffee
    - Open your browser, go to [http://localhost:9100/](http://localhost:9100/) and enjoy :)
    

### 1. Register your app to tiNiZen
- - - 

Please contact with tiNiZen supporter (see contact list). Then they will provide to you `client_id` and `client_secret` for your-app.

Contact list:

	- Lộc Nguyễn: loc.nguyen@tiniplanet.com
    
	- Huy Mai: huy.mai@tiniplanet.com
    
	- Tùng Vũ: tung.vu@tiniplanet.com
    


### 2. Inserting a tiNiZen login button on your-app
- - - 

In your site (example index.html), add button with javascript:

``` html

<button id="login" onclick="openTinizenLogin()">Login</button>

```

``` javascript

<script type="text/javascript">
    var loginWindow = null;
    var openTinizenLogin= function() {
      loginWindow = window.open('/login-redirect', "loginWindow", "height=600,width=700");
    }
</script>

```

When user click button, yoursite will open new popup web with URI `/login-redirect`

### 3. Cross-domain to tiNiZen login form
- - - 

When your-popup-site, it will be redirect to /dialog/authorize of tiNiZen. If you logged before, it will show tiNiZen decison form. Otherwise, it show tiNiZen loggin form.

`/login-redirect`is simple page:

``` html
<html>
   <head></head>
   <body>
      <script type="text/javascript">
         <!--
         
         dialogAuthorizeURL is parameter, example:
         
         var tinizen_base = "http://tinizen.com/api"
         var dialog_authorize_uri = "/dialog/authorize"
         // Please encode URI of client_redirect_uri
         var client_redirect_uri = "http://<yours-domain>/callback"
         var client_id = "<client-id-at-step1>"
         
         dialogAuthorizeUrl = tinizen_base + dialog_authorize_uri +
            "reponse_type=code&redirect_uri=" + "client_redirect_uri" +
            "&scope=email&client_id=" + client_id
         
         -->
         window.location = "!{dialogAuthorizeURL}";
      </script>
   </body>
</html>

```

Description of dialog authorize URI:

- `tinizen_base`: tinizen domain
- `dialog_authorize_uri`: url to authorize 
- `client_redirect_uri`: callback URL of your-app
- `client_id`: client_id of step 1
- `response_type`: always `code`
- `scope`:  tiNizen customer fields that your-app need access, example: emails, fullname, phone, point, mileage...
 

### 4. Desicion form
- - -

If user loggin successful, it will require user allows your-app that can collect certain information from user's tiNiZen Profile (i.e. name, email, point, vnd, etc.)

### 5. Listening callback on your server-side
- - - 

After user allow your-app permission access his tiNiZen resources at step 4, tiNizen will authorization for him and send callback request to your-server-side

So, your app need API that always listening for tiNiZen request, Example API your-server-side

``` coffeescript

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
    ## body: access-token string

    ## Note: successful responses have statusCode = 200

    ## So, you can assgin access-token to user request and return to "login_success"
    return res.render 'login_failed', getError err if err?
    return res.render 'login_failed', getError 'invalid_credentials' if resp.statusCode isnt 200
    req.session.token =
      token_type : 'Bearer'
      access_token: body.access_token

    res.render "login_success"


```


### 6. Display login success to user 
- - - 
When step 5 done, you can show login-success page to user


### 7. Get user information
- - - 

When person send request to your-app. To know this request is maded by guest or logged user, you can check `request.session.token` 


If request.session.token is a value of String. You can get this value and make request to tiNiZen API. Then, tiNiZen API validat this access-token and return result to your-app.

Example,

``` coffeescript

getMe = (token, cb)->

  ## This is example function make request to tiNizen API
  ## Header of request must be "Authorization: Bearer <access-token>"
  headers = {
    Authorization: "#{token.token_type} #{ token.access_token }"
  }

  ## uri: URL of tiNiZen API, eg: http://tinizen/api/me , get current logged user information
  request.get {
    uri: [config.tinizen.base, config.tinizen.get_me].join '/'
    json: true
    headers,
  }, (err, resp, body) ->
    ## if success, response from tiNiZen has statuCode 200 and response.body is user information 
    return cb err if err?
    return cb null, false if resp.statusCode isnt 200 or !body.account
    cb null, body


## This is middleware, filter all request coming, and know this is a Guest or Logged user
app.use (req, res, next)->
  ## req.session.token is null
  unless req.session.token
    res.locals.user = req.user = 'guess'
    next()
    return

  ## Ya, this request have access-token, made by logged user
  ## You can make request with access-token to tiNiZen API to get user information
  ## getMe is a function to do it :)
  getMe req.session.token, (err, me)->
    return next err if err?
    res.locals.user = req.user = me
    next()

```





