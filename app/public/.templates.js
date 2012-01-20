window.App.Templates = {'index/error': new HoganTemplate(function(cx,p,i){i = i || "";var c = [cx];var b = i + "";var _ = this;b += "ERROR";return b;;}),
'index/index': new HoganTemplate(function(cx,p,i){i = i || "";var c = [cx];var b = i + "";var _ = this;b += "<section id=\"play\">";b += "\n" + i;b += "  <div class=\"menu\">";b += "\n" + i;b += "    <div id=\"stats\">";b += "\n" + i;b += "      <div class=\"purse statholder stackable\">";b += "\n" + i;b += "        <div class=\"stat icon stackable\"><img class=\"\" src=\"/img/icons/coins.png\" alt=\"Coins\"></div>";b += "\n" + i;b += "        <div class=\"stat stackable\" id=\"purse_value_container\">";b += "\n" + i;b += "          <span class=\"menutext\" id=\"purse_value\">";b += "\n" + i;b += "            ";if(_.s(_.f("player",c,p,1),c,p,0,348,364, "{{ }}")){b += _.rs(c,p,function(c,p){ var b = "";b += (_.v(_.d("player.purse",c,p,0)));return b;});c.pop();}else{b += _.b; _.b = ""};b += "\n" + i;b += "            ";if (!_.s(_.f("player",c,p,1),c,p,1,0,0,"")){b += "- -";};b += "\n" + i;b += "          </span>";b += "\n" + i;b += "        </div>";b += "\n" + i;b += "        <div class=\"clear\"></div>";b += "\n" + i;b += "      </div>";b += "\n" + i;b += "\n" + i;b += "      <div class=\"divider stackable\">&nbsp;</div>";b += "\n" + i;b += "\n" + i;b += "      <div class=\"leaderboards statholder stackable\">";b += "\n" + i;b += "        <div class=\"stat icon stackable\"><a href=\"#\"><img class=\"\" src=\"/img/icons/trophy.png\" alt=\"Leaderboard Trophy\"></a></div>";b += "\n" + i;b += "        <div class=\"stat stackable\"><a href=\"#\">Leaderboards</a></div>";b += "\n" + i;b += "        <div class=\"clear\"></div>";b += "\n" + i;b += "      </div>";b += "\n" + i;b += "      <div class=\"clear\"></div>";b += "\n" + i;b += "    </div>";b += "\n" + i;b += "    <div class=\"clear\"></div>";b += "\n" + i;b += "  </div>";b += "\n" + i;b += "  ";b += "\n" + i;b += "  <div id=\"jsnoscript\">";b += "\n" + i;b += "    <p>This website requires JavaScript to enjoy (for the moment).</p>";b += "\n" + i;b += "  </div>";b += "\n" + i;b += "\n" + i;b += "  <div id=\"alltables\">";b += "\n" + i;b += "  </div>";b += "\n" + i;b += "\n" + i;b += "  <div id=\"current_table\">";b += "\n" + i;b += "  </div>";b += "\n" + i;b += "  ";b += "\n" + i;b += _.rp("common-radialui",c[c.length - 1],p,"  ");b += "</section>";b += "\n" + i;b += "\n" + i;b += "\n" + i;b += "\n" + i;b += _.rp("common-docs",c[c.length - 1],p,"");b += "\n" + i;b += _.rp("common-colophon",c[c.length - 1],p,"");b += "\n" + i;b += _.rp("common-minifooter",c[c.length - 1],p,"");return b;;}),
'layout': new HoganTemplate(function(cx,p,i){i = i || "";var c = [cx];var b = i + "";var _ = this;b += "<!doctype html>";b += "\n" + i;b += "<!--[if lt IE 7]> <html class=\"no-js ie6 oldie\" lang=\"en\"> <![endif]-->";b += "\n" + i;b += "<!--[if IE 7]>    <html class=\"no-js ie7 oldie\" lang=\"en\"> <![endif]-->";b += "\n" + i;b += "<!--[if IE 8]>    <html class=\"no-js ie8 oldie\" lang=\"en\"> <![endif]-->";b += "\n" + i;b += "<!--[if gt IE 8]><!--> <html class=\"no-js\" lang=\"en\"> <!--<![endif]-->";b += "\n" + i;b += "  <head>";b += "\n" + i;b += "    <meta charset=\"utf-8\">";b += "\n" + i;b += "    <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge,chrome=1\">";b += "\n" + i;b += "\n" + i;b += "    <title>Blackjack | vanscribe.com</title>";b += "\n" + i;b += "    <meta name=\"description\" content=\"\">";b += "\n" + i;b += "    <meta name=\"author\" content=\"\">";b += "\n" + i;b += "\n" + i;b += "    <meta name=\"viewport\" content=\"user-scalable=no,initial-scale=1.0,maximum-scale=1.0,minimum-scale=1.0,width=device-width\">";b += "\n" + i;b += "    <meta name=\"apple-mobile-web-app-capable\" content=\"yes\"/>";b += "\n" + i;b += "\n" + i;b += "    <!-- CSS concatenated and minified via ant build script-->";b += "\n" + i;b += "    <link rel=\"stylesheet\" href=\"http://twitter.github.com/bootstrap/1.4.0/bootstrap.min.css\">";b += "\n" + i;b += "    <link rel=\"stylesheet\" href=\"/static/css/";b += (_.v(_.d("assetsCacheHashes.css",c,p,0)));b += "/style.css\">";b += "\n" + i;b += "    <!-- end CSS-->";b += "\n" + i;b += "\n" + i;b += "    <script src=\"/js/libs/modernizr-2.0.6.min.js\"></script>";b += "\n" + i;b += "    <script type=\"text/javascript\" src=\"http://use.typekit.com/crr3srf.js\"></script>";b += "\n" + i;b += "    <script type=\"text/javascript\">try{Typekit.load();}catch(e){}</script>";b += "\n" + i;b += "  </head>";b += "\n" + i;b += "  <body lang=\"en\" class=\"vanscribe\">";b += "\n" + i;b += "    <div id=\"container\">";b += "\n" + i;b += _.rp("common-masthead",c[c.length - 1],p,"      ");b += "      <div class=\"container\">";b += "\n" + i;b += "        ";b += (_.f("body",c,p,0));b += "\n" + i;b += "      </div>";b += "\n" + i;b += _.rp("common-footer",c[c.length - 1],p,"      ");b += "    </div>";b += "\n" + i;b += "\n" + i;b += "    <script src=\"//ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js\"></script>";b += "\n" + i;b += "    <script>window.jQuery || document.write('<script src=\"/js/libs/jquery-1.6.2.min.js\"><\\/script>')</script>";b += "\n" + i;b += "\n" + i;b += "    <!-- scripts concatenated and minified via ant build script-->";b += "\n" + i;b += "    <script defer src=\"/static/js/";b += (_.v(_.d("assetsCacheHashes.js",c,p,0)));b += "/client.js\"></script>";b += "\n" + i;b += "    <!-- end scripts-->";b += "\n" + i;b += "\n" + i;b += "    <script> // Google Analytics";b += "\n" + i;b += "      window._gaq = [['_setAccount','UA-28296899-1'],['_trackPageview'],['_trackPageLoadTime']];";b += "\n" + i;b += "      Modernizr.load({";b += "\n" + i;b += "        load: ('https:' == location.protocol ? '//ssl' : '//www') + '.google-analytics.com/ga.js'";b += "\n" + i;b += "      });";b += "\n" + i;b += "    </script>";b += "\n" + i;b += "\n" + i;b += "    <!--[if lt IE 7 ]>";b += "\n" + i;b += "      <script src=\"//ajax.googleapis.com/ajax/libs/chrome-frame/1.0.3/CFInstall.min.js\"></script>";b += "\n" + i;b += "      <script>window.attachEvent('onload',function(){CFInstall.check({mode:'overlay'})})</script>";b += "\n" + i;b += "    <![endif]-->";b += "\n" + i;b += "  </body>";b += "\n" + i;b += "</html>";b += "\n";return b;;}),
'partials/alerts/warning': new HoganTemplate(function(cx,p,i){i = i || "";var c = [cx];var b = i + "";var _ = this;b += "<div class=\"alert-message warning\">";b += "\n" + i;b += "  <a class=\"close\" href=\"#\">×</a>";b += "\n" + i;b += "  <p>Click Deal to start game</p>";b += "\n" + i;b += "</div>";return b;;}),
'partials/blackjack/card': new HoganTemplate(function(cx,p,i){i = i || "";var c = [cx];var b = i + "";var _ = this;if(_.s(_.f("cards",c,p,1),c,p,0,10,60, "{{ }}")){b += _.rs(c,p,function(c,p){ var b = "";b += "  <img class=\"card\" src=\"/img/cards/";b += (_.v(_.f("id",c,p,0)));b += ".png\">";b += "\n";return b;});c.pop();}else{b += _.b; _.b = ""};return b;;}),
'partials/blackjack/dealer': new HoganTemplate(function(cx,p,i){i = i || "";var c = [cx];var b = i + "";var _ = this;b += "<div class=\"player dealer\">";b += "\n" + i;b += "  <div class=\"seat\">";b += "\n" + i;b += "    <div class=\"user\">";b += "\n" + i;b += "      <div class=\"avatar\">";b += "\n" + i;b += "        <img class=\"\" src=\"/img/icons/dealer.png\" alt=\"Dealer avatar\">";b += "\n" + i;b += "      </div>";b += "\n" + i;b += "      <div class=\"username\">";b += "\n" + i;b += "        <p>Dealer</p>";b += "\n" + i;b += "      </div>";b += "\n" + i;b += "    </div>";b += "\n" + i;b += "    <div class=\"playingCards\">";b += "\n" + i;b += "      <div class=\"hand\">";b += "\n" + i;b += "        ";b += "\n" + i;b += "      </div>";b += "\n" + i;b += "    </div>";b += "\n" + i;b += "    <div class=\"clear\"></div>";b += "\n" + i;b += "  </div>";b += "\n" + i;b += "</div>";return b;;}),
'partials/blackjack/emptyseat': new HoganTemplate(function(cx,p,i){i = i || "";var c = [cx];var b = i + "";var _ = this;if(_.s(_.f("id",c,p,1),c,p,0,7,86, "{{ }}")){b += _.rs(c,p,function(c,p){ var b = "";b += "<div class=\"emptyseat\" id=\"";b += (_.v(_.f("id",c,p,0)));b += "\">";b += "\n" + i;b += "  <div class=\"seat\">";b += "\n" + i;b += "    ";b += "\n" + i;b += "  </div>";b += "\n" + i;b += "</div>";b += "\n";return b;});c.pop();}else{b += _.b; _.b = ""};return b;;}),
'partials/blackjack/listtables': new HoganTemplate(function(cx,p,i){i = i || "";var c = [cx];var b = i + "";var _ = this;b += "<h3>Lobby <small>Click any open table!</small></h3>";b += "\n" + i;b += "<div class=\"tables\">";b += "\n" + i;b += "  <div class=\"table heading\">";b += "\n" + i;b += "    <div class=\"name\">";b += "\n" + i;b += "      <p>Table Name</p>";b += "\n" + i;b += "    </div>";b += "\n" + i;b += "    <div class=\"seats\">";b += "\n" + i;b += "      <p>Seats</p>";b += "\n" + i;b += "    </div>";b += "\n" + i;b += "    <div class=\"locked\">";b += "\n" + i;b += "      <p>&#x1f512;</p>";b += "\n" + i;b += "    </div>";b += "\n" + i;b += "  </div>";b += "\n" + i;if(_.s(_.f("tables",c,p,1),c,p,0,296,591, "{{ }}")){b += _.rs(c,p,function(c,p){ var b = "";b += "    <div class=\"table\">";b += "\n" + i;b += "      <div class=\"name\"><a id=\"";b += (_.v(_.f("name",c,p,0)));b += "\" class=\"";if(_.s(_.f("open",c,p,1),c,p,0,378,382, "{{ }}")){b += _.rs(c,p,function(c,p){ var b = "";b += "open";return b;});c.pop();}else{b += _.b; _.b = ""};b += "\" href=\"#table/";b += (_.v(_.f("name",c,p,0)));b += "\">Table ";b += (_.v(_.f("name",c,p,0)));b += "</a></div>";b += "\n" + i;b += "      <div class=\"seats\">";b += (_.v(_.f("taken",c,p,0)));b += "/";b += (_.v(_.f("seats",c,p,0)));b += "</div>";b += "\n" + i;b += "      <div class=\"locked\">";if(_.s(_.f("private",c,p,1),c,p,0,530,533, "{{ }}")){b += _.rs(c,p,function(c,p){ var b = "";b += "yes";return b;});c.pop();}else{b += _.b; _.b = ""};if (!_.s(_.f("private",c,p,1),c,p,1,0,0,"")){b += "no";};b += "</div>";b += "\n" + i;b += "    </div>";b += "\n";return b;});c.pop();}else{b += _.b; _.b = ""};b += "  <div class=\"clear\"></div>";b += "\n" + i;b += "</div>";return b;;}),
'partials/blackjack/player': new HoganTemplate(function(cx,p,i){i = i || "";var c = [cx];var b = i + "";var _ = this;b += "<div class=\"player self\" id=\"";b += (_.v(_.f("username",c,p,0)));b += "\">";b += "\n" + i;b += "  <div class=\"seat\">";b += "\n" + i;b += "    <div class=\"user\">";b += "\n" + i;b += "      <div class=\"avatar\">";b += "\n" + i;b += "        <img class=\"\" src=\"/img/icons/user.png\" alt=\"Avatar Placeholder\">";b += "\n" + i;b += "      </div>";b += "\n" + i;b += "      <div class=\"username\">";b += "\n" + i;b += "        <p>";b += (_.v(_.f("username",c,p,0)));b += "</p>";b += "\n" + i;b += "      </div>";b += "\n" + i;b += "    </div>";b += "\n" + i;b += "    <div class=\"playingCards\">";b += "\n" + i;b += "      <div class=\"hand\">";b += "\n" + i;b += "        ";b += "\n" + i;b += "      </div>";b += "\n" + i;b += "    </div>";b += "\n" + i;b += "    <div class=\"clear\"></div>";b += "\n" + i;b += "  </div>";b += "\n" + i;b += "</div>";return b;;}),
'partials/blackjack/players': new HoganTemplate(function(cx,p,i){i = i || "";var c = [cx];var b = i + "";var _ = this;b += "<div class=\"player\" id=\"";b += (_.v(_.f("username",c,p,0)));b += "\">";b += "\n" + i;b += "  <div class=\"seat\">";b += "\n" + i;b += "    <div class=\"user\">";b += "\n" + i;b += "      <div class=\"avatar\">";b += "\n" + i;b += "        <img class=\"\" src=\"/img/icons/user.png\" alt=\"Avatar Placeholder\">";b += "\n" + i;b += "      </div>";b += "\n" + i;b += "      <div class=\"username\">";b += "\n" + i;b += "        <p>";b += (_.v(_.f("username",c,p,0)));b += "</p>";b += "\n" + i;b += "      </div>";b += "\n" + i;b += "    </div>";b += "\n" + i;b += "    <div class=\"playingCards\">";b += "\n" + i;b += "      <div class=\"hand\">";b += "\n" + i;b += "        ";b += "\n" + i;b += "      </div>";b += "\n" + i;b += "    </div>";b += "\n" + i;b += "    <div class=\"clear\"></div>";b += "\n" + i;b += "  </div>";b += "\n" + i;b += "</div>";return b;;}),
'partials/blackjack/table': new HoganTemplate(function(cx,p,i){i = i || "";var c = [cx];var b = i + "";var _ = this;if(_.s(_.f("table",c,p,1),c,p,0,10,580, "{{ }}")){b += _.rs(c,p,function(c,p){ var b = "";b += "  <div class=\"current_table\">";b += "\n" + i;b += "    <div id=\"dealer-box\">";b += "\n" + i;b += _.rp("blackjack-dealer",c[c.length - 1],p,"      ");b += "    </div>";b += "\n" + i;b += "\n" + i;b += "    <div class=\"player-box\">";b += "\n" + i;if(_.s(_.f("player",c,p,1),c,p,0,155,194, "{{ }}")){b += _.rs(c,p,function(c,p){ var b = "";b += _.rp("blackjack-player",c[c.length - 1],p,"        ");return b;});c.pop();}else{b += _.b; _.b = ""};b += "    </div>";b += "\n" + i;b += "\n" + i;b += "    <div class=\"players-boxes\">";b += "\n" + i;if(_.s(_.f("players",c,p,1),c,p,0,268,308, "{{ }}")){b += _.rs(c,p,function(c,p){ var b = "";b += _.rp("blackjack-players",c[c.length - 1],p,"        ");return b;});c.pop();}else{b += _.b; _.b = ""};b += "      ";b += "\n" + i;if(_.s(_.f("emptyseats",c,p,1),c,p,0,349,391, "{{ }}")){b += _.rs(c,p,function(c,p){ var b = "";b += _.rp("blackjack-emptyseat",c[c.length - 1],p,"        ");return b;});c.pop();}else{b += _.b; _.b = ""};b += "    </div>";b += "\n" + i;b += "    <div class=\"clear\"></div>";b += "\n" + i;b += "  </div>";b += "\n" + i;b += "  <div id=\"statuslog\">";b += "\n" + i;b += "    <h4>Status<small></small></h4>";b += "\n" + i;b += "  </div>";b += "\n" + i;b += "  <div id=\"gamelog\">";b += "\n" + i;b += "    <h4>Game History</h4>";b += "\n" + i;b += "  </div>";b += "\n";return b;});c.pop();}else{b += _.b; _.b = ""};return b;;}),
'partials/common/colophon': new HoganTemplate(function(cx,p,i){i = i || "";var c = [cx];var b = i + "";var _ = this;b += "<section id=\"colophon\" name=\"colophon\">";b += "\n" + i;b += "  <h1>Colophon</h1>";b += "\n" + i;b += "  <h3>Statistics</h3>";b += "\n" + i;b += "  <dl>";b += "\n" + i;b += "    <!-- <dt>Whoa, I spent over 144 hours on this.</dt> -->";b += "\n" + i;b += "    <dt>Codebase is 20MB gzipped. O_o (according to Heroku)</dt>";b += "\n" + i;b += "    <dd>4033 lines of CoffeeScript</dd>";b += "\n" + i;b += "    <dd>3 lines of JavaScript</dd>";b += "\n" + i;b += "    <dd>446 lines of HTML</dd>";b += "\n" + i;b += "    <dd>4 icons created from scratch</dd>";b += "\n" + i;b += "    <dd>TBH, stopped doing unittests 25% of the way through.</dd>";b += "\n" + i;b += "    <dd>more info to be added (TBA)</dd>";b += "\n" + i;b += "    <dt>Custom tools created:</dt>";b += "\n" + i;b += "    <dd>falling asleep... TBA later</dd>";b += "\n" + i;b += "  </dl>";b += "\n" + i;b += "  ";b += "\n" + i;b += "  <h3>Learned</h3>";b += "\n" + i;b += "  <dl>";b += "\n" + i;b += "    <dt><a href=\"http://heroku.com\">Heroku <img src=\"/img/icons/newlink.gif\"></a></dt>";b += "\n" + i;b += "    <dd>My first time using it.  Wow did it take some elbow grease.</dd>";b += "\n" + i;b += "    <dt><a href=\"http://beaucollins.github.com/radial-menu/\">Radial Menu <img src=\"/img/icons/newlink.gif\"></a></dt>";b += "\n" + i;b += "    <dd>I could watch it jiggle all day.</dd>";b += "\n" + i;b += "    <dt><a href=\"http://framelessgrid.com/\">Frameless <img src=\"/img/icons/newlink.gif\"></a></dt>";b += "\n" + i;b += "    <dd>Fixed-width responsive layouts ftw!</dd>";b += "\n" + i;b += "    <dd>I like how the Leaderboards trophy icon just peeks at you in mobile width.</dd>";b += "\n" + i;b += "    <dt><a href=\"http://twitter.github.com/hogan.js/\">Hogan.js <img src=\"/img/icons/newlink.gif\"></a></dt>";b += "\n" + i;b += "    <dd>Had a LOT of bugs to deal with; but it got really nice and pleasant after I nudged the kinks.</dd>";b += "\n" + i;b += "    <dt><a href=\"http://lesscss.org/\">LessCSS  <img src=\"/img/icons/newlink.gif\"></a>";b += "\n" + i;b += "    <dd>I'm still undecided if this is better than SCSS. Nicer for somethings but both kinda lacking.</dd>";b += "\n" + i;b += "    <dt><a href=\"http://visionmedia.github.com/mocha/\">Mocha <img src=\"/img/icons/newlink.gif\"></a></dt>";b += "\n" + i;b += "    <dd>Better TDD/BDD framework than what I was using; needs coverage support though.</dd>";b += "\n" + i;b += "    <dt>Backbone.js</dt>";b += "\n" + i;b += "    <dd>First time using new version</dd>";b += "\n" + i;b += "    <dt>... More TBA</dt>";b += "\n" + i;b += "  </dl>";b += "\n" + i;b += "  ";b += "\n" + i;b += "  <h3>Used</h3>";b += "\n" + i;b += "  <dl>";b += "\n" + i;b += "  <dt>Node.js</dt>";b += "\n" + i;b += "    <dt>... TBA</dt>";b += "\n" + i;b += "  </dl>";b += "\n" + i;b += "<!--   <ul>";b += "\n" + i;b += "    <li></li>";b += "\n" + i;b += "    <li><a href=\"http://twitter.github.com/bootstrap/\">Twitter Bootstrap</a></li>";b += "\n" + i;b += "    <li><a href=\"http://code.google.com/p/vectorized-playing-cards/\">Vectorized Playing Cards</a></li>";b += "\n" + i;b += "    <li>\"<a href=\"http://selfthinker.github.com/CSS-Playing-Cards/\">CSS-Playing-Cards</a>\" by Anika Henke &lt;anika@selfthinker.org&gt;</li>";b += "\n" + i;b += "    <li>\"<a href=\"http://beaucollins.github.com/radial-menu\">Radial Menu</a>\" by Beau Collins</li>";b += "\n" + i;b += "  </ul> -->";b += "\n" + i;b += "</section>";return b;;}),
'partials/common/docs': new HoganTemplate(function(cx,p,i){i = i || "";var c = [cx];var b = i + "";var _ = this;b += "<section id=\"read\" name=\"read\">";b += "\n" + i;b += "  <!-- Documentation section goes here -->";b += "\n" + i;b += "  <h1>&#x2663; Blackjack</h1>";b += "\n" + i;b += "  <h4>Instructions</h4>";b += "\n" + i;b += "  <p>Click a table name to join (if seats open)</p>";b += "\n" + i;b += "  <p>Red circle opens action menu</p>";b += "\n" + i;b += "  <p>H = Hit, St = Stand, D = Deal</p>";b += "\n" + i;b += "  <p>Click the (i) to go back to Lobby</p>";b += "\n" + i;b += "  <br/>";b += "\n" + i;b += "  <h4>Rationale</h4>";b += "\n" + i;b += "  <p class=\"strikethrough\">Best played using an iPhone.</p>";b += "\n" + i;b += "  <p>(Or shrink the width of your browser for maximum effect)</p>";b += "\n" + i;b += "  <p>This game was designed, built, &amp; deployed over a week to demonstrate a wide range of artistic and technical skills... but ends up being an embarassing beta.  Nevertheless, I got to learn some cool things and the bugs will eventually go away.</p>";b += "\n" + i;b += "  <p>In addition to being a showcase, I forced myself to learn several new things at the cost of time (and possibly health). Some of these cool toys are listed in the Colophon.</p> ";b += "\n" + i;b += "  <p>A few of the more annoying Bug List parts will get fixed now that it is live... but most likely after a power nap.</p>";b += "\n" + i;b += "</section>";b += "\n" + i;b += "\n" + i;b += "<section id=\"incomplete\">";b += "\n" + i;b += "  <h2>Bug List / Feat Requests</h2>";b += "\n" + i;b += "  <dl>";b += "\n" + i;b += "    <dt>Heroku logs are flipping out. </dt>";b += "\n" + i;b += "    <dd>causing possible memory leaks and weird numbers to show up.</dd>";b += "\n" + i;b += "    <dt>iPhone Radial button click area is too small</dt>";b += "\n" + i;b += "    <dt>Some tables get phantom users, fix coming soonish.</dt>";b += "\n" + i;b += "    <dt>Lobby view should be toggle-able</dt>";b += "\n" + i;b += "    <dd>Lobby \"live view\" listening is disabled for performance</dd>";b += "\n" + i;b += "    <dt class=\"strikethrough\">Loading message</dt>";b += "\n" + i;b += "    <dd>Heroku apparently has lag spikes = not clear that you're waiting</dd>";b += "\n" + i;b += "    <dt>Better UI/UX improvements</dt>";b += "\n" + i;b += "    <dd>Card sum indicators</dd>";b += "\n" + i;b += "    <dd><span class='strikethrough'>Status message box</span> bugs out the log though</dd>";b += "\n" + i;b += "    <dd>Need to call attention to radial buttons at prompts</dd>";b += "\n" + i;b += "    <dd>Not enough headers/title sections for chunks of the page.</dd>";b += "\n" + i;b += "    <dd>Action bar tooltips so that you can tell what D, St, &amp; H are.</dd>";b += "\n" + i;b += "    <dd>Deal &amp; Stand should force Deal if game is over - so should status box.</dd>";b += "\n" + i;b += "    <dd>Needs a better way to get back to Table list.</dd>";b += "\n" + i;b += "    <dd>Disabling all of the console.log messages would be nice.</dd>";b += "\n" + i;b += "    <dt>Multiplayer rooms have been disabled.</dt>";b += "\n" + i;b += "    <dt>Chat is disabled until I get can performance up on Heroku</dt>";b += "\n" + i;b += "    <dd>A lot of the work is done for this on both front &amp; back end but it gets a little hairy over XHR.</dd>";b += "\n" + i;b += "    <dt>Money/data persistence is not fully implemented.</dt>";b += "\n" + i;b += "    <dt>Non-mobile media query styling is woefully incomplete.</dt>";b += "\n" + i;b += "    <dd>So on a big screen, this doesn't do much for your eyes.</dd>";b += "\n" + i;b += "    <dt>Leaderboards have been disabled.</dt>";b += "\n" + i;b += "    <dt>Unobtrusive version is incomplete</dt>";b += "\n" + i;b += "    <dd>For those pesky JavaScript haters.</dd>";b += "\n" + i;b += "    <dt>Username &amp; Avatar customization is disabled. (related to persistence)</dt>";b += "\n" + i;b += "    <dt>Bet customization is disabled until UI is improved</dt>";b += "\n" + i;b += "    <dt>Cli-side JS file hashing to trigger graceful page load on deploy</dt>";b += "\n" + i;b += "    <dt>... a few others, to be added</dt>";b += "\n" + i;b += "  </dl>";b += "\n" + i;b += "</section>";b += "\n" + i;b += "\n" + i;b += "<section id=\"working\">";b += "\n" + i;b += "  <h2>Stuff that works</h2>";b += "\n" + i;b += "  <dl>";b += "\n" + i;b += "    <dt>Lobby System</dt>";b += "\n" + i;b += "    <dd>Move from Table to Table</dd>";b += "\n" + i;b += "    <dt>Basic Gameplay</dt>";b += "\n" + i;b += "    <dd>Deal, Hit, Stand - Blackjack pays 3:2</dd>";b += "\n" + i;b += "    <dd>The casino will bail you out if you go negative</dd>";b += "\n" + i;b += "    <dd>Basic paper log keeps track of wins and losses.</dd>";b += "\n" + i;b += "    <dt>... a few others, to be added</dt>";b += "\n" + i;b += "  </dl>";b += "\n" + i;b += "</section>";b += "\n";return b;;}),
'partials/common/footer': new HoganTemplate(function(cx,p,i){i = i || "";var c = [cx];var b = i + "";var _ = this;b += "<footer id=\"footer\">";b += "\n" + i;b += "  <!-- Footer goes here. -->";b += "\n" + i;b += "</footer>";return b;;}),
'partials/common/masthead': new HoganTemplate(function(cx,p,i){i = i || "";var c = [cx];var b = i + "";var _ = this;b += "<header id=\"masthead\">";b += "\n" + i;b += "  <div class=\"heading-outer\">";b += "\n" + i;b += "    <div class=\"heading\">";b += "\n" + i;b += "      <div class=\"fake_icon\"><a href=\"/\">&#x2663;</a></div>";b += "\n" + i;b += "      <div class=\"h1\"><a href=\"/\">Blackjack</a></div>";b += "\n" + i;b += "      <div class=\"help\">";b += "\n" + i;b += "        <a href=\"#lobby\"><img src=\"/img/icons/info.png\" alt=\"Help\"></a>";b += "\n" + i;b += "      </div>";b += "\n" + i;b += "      <div class=\"clear\"></div>";b += "\n" + i;b += "    </div>";b += "\n" + i;b += "    ";b += "\n" + i;b += "  </div>";b += "\n" + i;b += "  ";b += "\n" + i;b += "<!--   <p></p>";b += "\n" + i;b += "  <nav id=\"nav\">";b += "\n" + i;b += "    <ul>";b += "\n" + i;b += "      <li>";b += "\n" + i;b += "        <a href=\"#play\">";b += "\n" + i;b += "          <div class=\"fake_icon\">&#x2660;</div>";b += "\n" + i;b += "          <span>Play</span>";b += "\n" + i;b += "        </a>";b += "\n" + i;b += "      </li>";b += "\n" + i;b += "      <li>";b += "\n" + i;b += "        <a href=\"#read\">";b += "\n" + i;b += "          <div class=\"fake_icon\">&#x2318;</div>";b += "\n" + i;b += "          <span>About</span>";b += "\n" + i;b += "        </a>";b += "\n" + i;b += "      </li>";b += "\n" + i;b += "    </ul>";b += "\n" + i;b += "  </nav> -->";b += "\n" + i;b += "</header>";return b;;}),
'partials/common/minifooter': new HoganTemplate(function(cx,p,i){i = i || "";var c = [cx];var b = i + "";var _ = this;b += "<section id=\"minifooter\">";b += "\n" + i;b += "  <p>Designed &amp; built by <br/><a href=\"http://twitter.com/thegoleffect\">@thegoleffect</a><br/> in California</p>";b += "\n" + i;b += "</section>";return b;;}),
'partials/common/noscript': new HoganTemplate(function(cx,p,i){i = i || "";var c = [cx];var b = i + "";var _ = this;b += "<noscript>";b += "\n" + i;b += "  <div class=\"noscript\">JavaScript is required to play.</div>";b += "\n" + i;b += "</noscript>";b += "\n" + i;b += "<script type=\"text/javascript\">";b += "\n" + i;b += "  ";b += "\n" + i;b += "</script>";return b;;}),
'partials/common/radialui': new HoganTemplate(function(cx,p,i){i = i || "";var c = [cx];var b = i + "";var _ = this;b += "<!-- <nav id=\"bet\">";b += "\n" + i;b += "  <div class=\"label\">Bet</div>";b += "\n" + i;b += "  <a href=\"#\">100</a>";b += "\n" + i;b += "  <ul>";b += "\n" + i;b += "    <li><a href=\"#\">Max</a></li>";b += "\n" + i;b += "    <li><a href=\"#\">+10</a></li>";b += "\n" + i;b += "    <li><a href=\"#\">Min</a></li>";b += "\n" + i;b += "  </ul>";b += "\n" + i;b += "</nav> -->";b += "\n" + i;b += "<nav id=\"actions\">";b += "\n" + i;b += "  <div class=\"label\">Actions</div>";b += "\n" + i;b += "  <a href=\"#\">+</a>";b += "\n" + i;b += "  <ul>";b += "\n" + i;b += "    <li><a class=\"actions_deal\" href=\"#\">D</a></li>";b += "\n" + i;b += "    <li><a class=\"actions_stand\" href=\"#\">St</a></li>";b += "\n" + i;b += "    <li><a class=\"actions_hit\" href=\"#\">H</a></li>";b += "\n" + i;b += "  </ul>";b += "\n" + i;b += "</nav>";return b;;}),
'partials/common/rulers': new HoganTemplate(function(cx,p,i){i = i || "";var c = [cx];var b = i + "";var _ = this;b += "<section id=\"rulers\">";b += "\n" + i;b += "  <figure id=\"grid\">";b += "\n" + i;b += "    <div class=\"col col1\"></div>";b += "\n" + i;b += "    <div class=\"col col2\"></div>";b += "\n" + i;b += "    <div class=\"col col3\"></div>";b += "\n" + i;b += "    <div class=\"col col4\"></div>";b += "\n" + i;b += "    <div class=\"col col5\"></div>";b += "\n" + i;b += "    <div class=\"col col6\"></div>";b += "\n" + i;b += "    <div class=\"col col7\"></div>";b += "\n" + i;b += "    <div class=\"col col8\"></div>";b += "\n" + i;b += "    <div class=\"col col9\"></div>";b += "\n" + i;b += "    <div class=\"col col10\"></div>";b += "\n" + i;b += "    <div class=\"col col11\"></div>";b += "\n" + i;b += "    <div class=\"col col12\"></div>";b += "\n" + i;b += "    <div class=\"col col13\"></div>";b += "\n" + i;b += "    <div class=\"col col14\"></div>";b += "\n" + i;b += "    <div class=\"col col15\"></div>";b += "\n" + i;b += "    <div class=\"col col16\"></div>";b += "\n" + i;b += "    <div class=\"col col17\"></div>";b += "\n" + i;b += "    <div class=\"col col18\"></div>";b += "\n" + i;b += "    <div class=\"col col19\"></div>";b += "\n" + i;b += "    <div class=\"col col20\"></div>";b += "\n" + i;b += "    <div class=\"col col21\"></div>";b += "\n" + i;b += "    <div class=\"col col22\"></div>";b += "\n" + i;b += "    <div class=\"col col23\"></div>";b += "\n" + i;b += "    <div class=\"col col24\"></div>";b += "\n" + i;b += "    <div class=\"col col25\"></div>";b += "\n" + i;b += "    <div class=\"col col26\"></div>";b += "\n" + i;b += "    <div class=\"col col27\"></div>";b += "\n" + i;b += "    <div class=\"col col28\"></div>";b += "\n" + i;b += "    <div class=\"col col29\"></div>";b += "\n" + i;b += "    <div class=\"col col30\"></div>";b += "\n" + i;b += "    <div class=\"col col31\"></div>";b += "\n" + i;b += "    <div class=\"col col32\"></div>";b += "\n" + i;b += "    <div class=\"col col33\"></div>";b += "\n" + i;b += "    <div class=\"col col34\"></div>";b += "\n" + i;b += "    <div class=\"col col35\"></div>";b += "\n" + i;b += "    <div class=\"col col36\"></div>";b += "\n" + i;b += "  </figure>";b += "\n" + i;b += "</section>";return b;;}),
'partials/common/session': new HoganTemplate(function(cx,p,i){i = i || "";var c = [cx];var b = i + "";var _ = this;b += "<script type=\"text/javascript\" charset=\"utf-8\">";b += "\n" + i;b += "      var sessionId = \"";b += (_.v(_.f("sessionId",c,p,0)));b += "\";";b += "\n" + i;b += "    </script>";return b;;}),
'partials/common/test': new HoganTemplate(function(cx,p,i){i = i || "";var c = [cx];var b = i + "";var _ = this;b += "<!--";b += "\n" + i;b += "<[element] class=\"card rank-[2|3|4|5|6|7|8|9|10|j|q|k|a] [diams|hearts|spades|clubs]\">";b += "\n" + i;b += "    <[element] class=\"rank\">[2|3|4|5|6|7|8|9|10|J|Q|K|A]</[element]>";b += "\n" + i;b += "    <[element] class=\"suit\">&[diams|hearts|spades|clubs];</[element]>";b += "\n" + i;b += "</[element]>";b += "\n" + i;b += "-->";b += "\n" + i;b += "\n" + i;b += "<section id=\"test\">";b += "\n" + i;b += "  <img src=\"/img/cards/Clubs/KC.png\">";b += "\n" + i;b += "</section>";return b;;})};
