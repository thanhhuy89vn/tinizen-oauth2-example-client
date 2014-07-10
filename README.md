tinizen-oauth2-example-client
=============================

In order to integrate tiNiZen login/signup with your site, you will first need to setup a tiNiZen application. To do this, follow the below steps:

1. Register your app to tiNiZen

Please contact with tiNiZen supporter (see contact list). Then they will provide to you `client_id` and `client_secret` for your site.


3. Inserting a tiNiZen login button on your site

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

3. Cross-domain to tiNiZen login form

When your-popup-site, it will be redirect to /dialog/authorize of tiNiZen. If you logged before, it will show tiNiZen decison form. Otherwise, it show tiNiZen loggin form. Please view more at diagram.

`/login-redirect`is simple page with

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
         var client_redirect_uri = "http://<yours-site>/callback"
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
- `client_redirect_uri`: callback URL of yoursite
- `client_id`: client_id of step 1
- `response_type`: always `code`
- `scope`:  tiNizen customer fields that your-site need access, example: emails, fullname, phone, point, mileage...
 

4. Desicion form

If user loggin successful, it will be require user allows your-site can collect certain information from user's tiNiZen Profile (i.e. name, email, point, vnd, etc.)

5. 

4. Listening callback on your server-side
