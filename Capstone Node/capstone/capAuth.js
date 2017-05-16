var express = require('express');
var app = express();
var https = require('https');
var fs = require('fs');
var path = require('path');
var r = require('rethinkdbdash')();

/////////////	PARSES HTTP BODIES
var bodyParser = require('body-parser');
app.use(bodyParser.urlencoded({ extended: false }));

/////////////	PASSPORT
var passport = require('passport');
require('./app/passport')(passport,r);
app.use(passport.initialize());

/////////////	ROUTES: /API, /LOGIN, /TEST
var api = express.Router();
require('./app/routes/api.js')(api,passport,r);
app.use('/api',api);

var account = express.Router();
require('./app/routes/account.js')(account,passport,r);
app.use('/account',account);

var test = express.Router();
require('./app/routes/test.js')(test,passport,r);
app.use('/test',test);

/////////////	USED TO CLEAR EXPIRES TOKENS
function clearExpiredTokens(){
	r.db('Capstone').table('Tokens').filter(r.row('expires').lt(r.now().toEpochTime())).delete().run().then(function(result){
		console.log("Clearing Expired Tokens");
		console.log("Expired Tokens Deleted: " + result['deleted']);
	})
}
var clearTokenEvent = setInterval(clearExpiredTokens, (1000*60*10) );

/////////////	STARTS THE SERVER
var options = {
	key : fs.readFileSync(__dirname + "/serverkeys/server.key"),
	cert : fs.readFileSync(__dirname + "/serverkeys/server.crt")
}
https.createServer(options, app).listen(8081, function () {
  console.log("Capstone Server Listening")
});
