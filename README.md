# Blackjack

## To run it yourself

* Uses Node v0.4.7 to maintain compatibility with Heroku.  v0.4.7 sucks.

* After installing 0.4.7, run `npm install` in the root directory.  

* `node server.js` will bootstrap the rest of the code base's CoffeeScript files.
   but you may have to install additional modules.  YMMV.  I use nave to isolate my node versions.


## 51-sec Breakdown

`/server.js` has the only 3 lines of JS in the entire code base.  It loads the real server:

`server.coffee` is set up in a nice, simple OOP fashion to more graceful interactivity.  Pop a REPL in there, debug in real-time - up close or remotely.  It also handles all of the middleware, sessions, etc.

Most App-specific code (tries) to be kept inside the /app folder in a typical MVC layout.  Config, Controllers, Models, Views, Public, routes, - pretty standard folder structure.  

Compiled/assetpacked "static" files are kept in `/public/src`: this includes .less css files & client side CoffeeScript.  Hogan.js templates are compiled separately.  The compilation steps are decoupled from the server in the Cakefile by design... but I normally hook them up so I don't have to restart on file save.  

Models store the bulk of the logic.  They're been rewritten repeatedly.

Nowjs & socket.io handle the bulk of the client-server communication.  You can find that stuff in `/app/controllers/nowjs/index.coffee` and many of the files in `/public/src/js/*`.  The former does a pretty good job of showing how parts are connected.  There are some callback-based set ups and some event/signal-based.

Client side stuff = mostly Backbone.js.  Everything is tightly packed into only a few views right now while I debug.  


## Highlights

The PRNG used by `/models/blackjack/deck.coffee` should generate 53 bits of precision and supplies a more random distribution than standard Math.random().

Programming style used here attempts to minimize ambiguity found in other CoffeeScript projects.  Parens are almost always used to indicate calling a function.

Hogan.js templates are mixed and matched between client & server.  

Nodemon + growlnotify = yay.  Restart automatically on editing server-side changes + notification when its done.  


Ok, that's it for me, I have to get some ZzzZzzzs.

