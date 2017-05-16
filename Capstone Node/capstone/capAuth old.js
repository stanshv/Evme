var express = require('express');
var app = express();

var https = require('https');
var bodyParser = require('body-parser');
var fs = require('fs');
//var r = require('rethinkdb');
//var tls = require('tls');
var path = require('path');
//var cookie = require('cookie-parser');
//var session = require('express-session');
// var randtoken = require('rand-token');
// var r = require('rethinkdbdash')({
//   pool: false,
//   cursor: true
// });
var passport = require('passport');
// var passportLocal = require('passport-local');
// var passportHTTP = require('passport-http');
var BearerStrategy = require('passport-http-bearer').Strategy;

var r = require('rethinkdbdash')();
//var RDBStore = require('express-session-rethinkdb')(session);
var options = {
	key : fs.readFileSync(__dirname + "/serverkeys/server.key"),
	cert : fs.readFileSync(__dirname + "/serverkeys/server.crt")
}

app.use(bodyParser.urlencoded({ extended: false }));
//app.use(r);

app.use(passport.initialize());



var api = express.Router();
require('./app/routes/api.js')(api,passport);
app.use('/api',api);

// var rdbStore = new RDBStore({
//   connectOptions: {
//     servers: [
//       { host: 'localhost', port: 28015 }
//       ]
//     ,
//     db: 'Capstone',
//     discovery: false,
//     pool: true,
//     buffer: 50,
//     max: 1000,
//     timeout: 20,
//     timeoutError: 1000
//   },
//   table: 'Tokens',
//   sessionTimeout: 1000 * 60,
//   flushInterval: 1000 * 60 * 1,
//   debug: false
// });

// app.use(session({
//   key: 'sid',
//   secret: 'my5uperSEC537(key)!',
//   cookie: { maxAge: 1000*200 },
//   store: rdbStore,
//   resave: false,
//   saveUninitialized: false
// }));

// app.use(cookie());


//app.use(cookie());

// app.use(session({
// 	secret : 'ABCD',
// 	resave: false,
// 	saveUninitialized: false
// }));

 
 // app.use(passport.session());

function clearExpiredTokens(){
	r.db('Capstone').table('Tokens').filter(r.row('expires').lt(r.now().toEpochTime())).delete().run().then(function(result){
		console.log("Clearing Expired Tokens");
		console.log("Expired Tokens Deleted: " + result['deleted']);
	})
}
var clearTokenEvent = setInterval(clearExpiredTokens, (1000*60*10) );

function verifyCred(username, password, done){
	if(username == password){
		done(null,{id: username, name: username});
	}
	else{
		done(null,null);
	}

}
// passport.use(new BearerStrategy({}, function(token, done){
// 	r.db('Capstone').table('Users3').filter(r.row('id').eq(token)).run().then(function(user){
// 		//if (err) { console.log("err:  " + err); return done(err); }
// 		if(!user) { console.log("no user"); return done(null,false); }
// 		console.log("user: "  + user[0]); 
// 		return done(null, user);
// 	});
// }));
passport.use(new BearerStrategy(function(token, done){
	r.db('Capstone').table('Tokens').get(token).run().then(function(result){
		if(result){
			done(null, result);			
		}
		else{
			//res.redirect('/login');
		 	done(null, false);
		}
	});
}));
// passport.use(new BearerStrategy({},
// 	function(token, done){
// 		if(token == "qwer"){
// 			done(null, {id: "testUser", name: "testName"});			
// 		}
// 		else{
// 		 	done(null, false);
// 		}
// 	}));



app.use('/testAPI', passport.authenticate('bearer', { session: false }));
app.use('/testAPI2', passport.authenticate('bearer', { session: false }));

// app.all('/auth/*', function(req, res, next) {
//   return passport.authenticate('bearer', { session: false }, function(err, user, info) {
//     if (err) {
//       return next(err);
//     }
//     if (!user) {
//       return res.status(401).send(my_json_object);
//     }
//     req.user = user;
//     return next();
//   })(req, res, next);
// });


// passport.use(new passportLocal.Strategy(verifyCred));

// passport.use(new passportHTTP.BasicStrategy(verifyCred));

passport.serializeUser(function(user, done){
	done(null, user.id);
});

passport.deserializeUser(function(id, done){
	//query DB here
	done(null, {id: id, name: id});
});

// function ensureAuthenticated(req,res,next){
// 	if(req.isAuthenticated()){
// 		next();
// 	}
// 	else{
// 		res.redirect('/login');
// 	}
// }

// var urlencodedParser = bodyParser.urlencoded({ extended: false })
var userTest = {
  "name" : "Test",
  "password" : "ABC123",
  "profession" : "Tester",
  "id": 4
}
var userMike = {
  "name" : "Mike!",
  "password" : "I<3Stan",
  "profession" : "Professional Charlie Sheen Impersonator",
  "id": 5
}

//app.use(express.static('.'));
app.get('/clearTokens', clearExpiredTokens);

app.get('/login', function(req,res){
	res.sendFile(path.join(__dirname + '/views/login.html'));
});

app.post('/login', logInGetToken);

app.get('/qtest', function(req,res) {
	var qvariable = req.query["email"];
	
	r.db('Capstone').table('Users3').filter(r.row('email').eq(qvariable)).run().then(function(result){
		res.end(JSON.stringify(result, null, 2));
	});
});

app.get('/testTokenAuth', function(req,res){
	res.sendFile(path.join(__dirname + '/views/tokentest.html'));
});
app.post('/testTokenAuth',  function(req,res){
	//res.redirect('/testAPI');
	res.send(req.headers);
});

app.get('/testLogin', function(req,res){
	res.sendFile(path.join(__dirname + '/views/login.html'));
});

app.get('/testAPI', function(req,res){
	res.json({SecretData: 'ABCDEF'});
});
app.get('/testAPI2', function(req,res){
	res.json({userID: req.user.userID});
});
app.get('/testAdd', addUser2, function(req,res){
	res.write({email: "USEREMAIL"});
	res.end();
});

app.get('/register', function(req,res){
	res.sendFile(path.join(__dirname + '/views/register.html'));
});

app.get('/dash', function(req,res){
	res.sendFile(path.join(__dirname + '/views/dash.html'));
});
app.get('/ind', function(req,res){
	res.redirect('/dash');
});

app.delete('/logout', logOut);

app.post('/testlog', logInGetToken);

app.get('/data', function(req,res){
	res.json([
		{value: "foo"},
		{value: "bar"},
		{value: "you"},
	])
});

// app.use('/api', passport.authenticate('basic', { session: false }));



app.post('/testToken', function( req, res){
	console.log("token gen");
	res.send(randtoken.generate(32)) 
});


app.get('/test', function( req, res){
	console.log("connection happened");
	res.send(JSON.stringify(userTest))
});
app.get('/mike', function( req, res){
	console.log("Mike Tested!");
	res.send(JSON.stringify(userMike))
});
app.get('/getuser', getUsersDash);

app.route('/adduser').post(addUser);
app.route('/checkUserExist').get(checkByEmail);
app.route('/checkAndAdd').post(checkAndAdd);


// var tlsServer = tls.createServer(options, app).listen(8081, function () {
//   console.log("TLS Capstone Server Listening")
// });
/*
app.get('/users/') // GET all users

app.put('/users/:email') // Create user 

app.get('/users/:email') // Get user by email
*/

https.createServer(options, app).listen(8081, function () {
  console.log("Capstone Server Listening")
});

// var server = app.listen(8081, function () {
//   console.log("Capstone Server Listening")
// })









////////////////////////////////////////////////////////////////
//////RESTFUL APIS
var connection = null;
function getUsersDash2(req, res){
	r.db('Capstone').table('Users3').run().then(function(result) {
		console.log("worked");
		res.end(JSON.stringify(result, null, 2));
	});
}
function logInGetToken(req, res){
	console.log("Logged In");
	var email = req.body.email;
	var pass = req.body.pass;
	//add .pluck
	r.db('Capstone').table('Users3').getAll(email, {index: 'email'}).run().then(function(result){
		if(result.length){
			if(pass != result[0]['pass']){
				res.json("Password did not match");
			}
			else{
				r.branch(
					r.db('Capstone').table('Tokens').getAll(result[0]['id'], {index: 'userID'}).count().gt(0),
  					r.db('Capstone').table('Tokens').getAll(result[0]['id'], {index: 'userID'}),
 					r.db('Capstone').table('Tokens').insert( {userID:result[0]['id'], created:(r.now().toEpochTime()),expires: (r.now().toEpochTime().add(60*5*1*1)) })
				).run().then(function(secondResult){
					res.send(secondResult);
				})		
			}
		}
		else{
			res.json("No user found");
		}
	});
}
function logOut(req, res){
	console.log("Logged Out");
	var token = req.body.token;
	r.db('Capstone').table('Tokens').get(token).delete().run().then(function(result){
		res.redirect('/login');
	});
}

function checkByEmail(req, res){
	console.log("email check");
	var email = req.query["email"];
	r.connect({db:'Capstone'}).then(function(conn){
		connection = conn;
		r.branch(
			r.db('Capstone').table('Users3').getAll(email, {index: 'email'}).count().gt(0),
  			true,
 			false
		)
		  .run(conn, function(err,result){
			if (err) throw err;
				var test = {"doesit":result};
				res.end(JSON.stringify(test, null, 2));
			conn.close();
		});
	});
}

function checkAndAdd(req, res){
	console.log("Check And Add");
	var fname = req.body.fname;
	var lname = req.body.lname;
	var email = req.body.email;
	var pass = req.body.pass;
	r.connect({db:'Capstone'}).then(function(conn){
		connection = conn;
		r.branch(
			r.db('Capstone').table('Users3').getAll(email, {index: 'email'}).count().gt(0),
  			{"doesit":true},
 			r.db('Capstone').table('Users3').insert({name:fname,lname:lname,email:email,pass:pass})
		)
		  .run(conn, function(err,result){
			if (err) throw err;
				console.log(result);
				res.end(JSON.stringify(result, null, 2));
				conn.close();
		});
	});
}

function addUser(req, res){
	console.log("Add User");
	var fname = req.body.fname;
	var lname = req.body.lname;
	var email = req.body.email;
	var pass = req.body.pass;
	r.connect({db:'Capstone'}).then(function(conn){
		connection = conn;
		r.table('Users3').insert({name:fname,lname:lname,email:email,pass:pass})
		  .run(conn, function(err,result){
				if (err) throw err;
				res.end(JSON.stringify(result, null, 2));
				conn.close();
		});
	});
}


function getUsers(req, res){
	r.connect({db:'Capstone'}).then(function(conn){
		connection = conn;
		r.table('Users3').run(conn, function(err,cursor){
			if (err) throw err;
			cursor.toArray(function(err,result){
				if (err) throw err;
				console.log(JSON.stringify(result, null, 2));
				var jsonob = {"result":result};
				//console.log(jsonob);
				res.send(JSON.stringify(jsonob, null, 2));
			})
			conn.close();
		});
	});
}
function addUser2(req, res, next){
	console.log("Add User");
	var fname = req.query["fname"];
	var lname = req.query["lname"];
	var email = req.query["email"];
	var pass = req.query["pass"];
	r.db('Capstone').table('Users4').insert(
	  {name:fname,lname:lname,email:email,pass:pass,token:randtoken.generate(32),expires: r.now().toEpochTime() }
	  ).run().then(function(result){
		//if (err) throw err;
		res.write(JSON.stringify(result, null, 2));
		next();
	});

}
function getUsersDash(req, res){
	r.db('Capstone').table('Users3').run().then(function(result) {
		console.log("worked");
		res.end(JSON.stringify(result, null, 2));
	});
}