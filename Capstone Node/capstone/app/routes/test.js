
module.exports = function(router,passport,r){

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

router.use('/getTest', passport.authenticate('bearer', { session: false }));
//router.use('/getMike', passport.authenticate('bearer', { session: false }));

router.get('/mike', function( req, res){
	console.log("Mike Tested!");
	res.send(JSON.stringify(userMike))
});

router.get('/test', function( req, res){
	console.log("connection happened");
	res.send(JSON.stringify(userTest))
});

router.get('/testAPI', function(req,res){
	res.json({SecretData: 'ABCDEF'});
});

router.get('/testAPI2', function(req,res){
	res.json({userID: req.user.userID});
});

router.get('/data', function(req,res){
	res.json([
		{value: "foo"},
		{value: "bar"},
		{value: "you"},
	])
});


router.get('/login', function(req,res){
	res.sendFile(path.join(__dirname + '/views/login.html'));
});

router.post('/login', logInGetToken);

router.get('/qtest', function(req,res) {
	var qvariable = req.query["email"];
	
	r.db('Capstone').table('Users3').filter(r.row('email').eq(qvariable)).run().then(function(result){
		res.end(JSON.stringify(result, null, 2));
	});
});

router.get('/testTokenAuth', function(req,res){
	res.sendFile(path.join(__dirname + '/views/tokentest.html'));
});
router.post('/testTokenAuth',  function(req,res){
	//res.redirect('/testAPI');
	res.send(req.headers);
});

router.get('/testLogin', function(req,res){
	res.sendFile(path.join(__dirname + '/views/login.html'));
});


router.get('/testAdd', addUser2, function(req,res){
	res.write({email: "USEREMAIL"});
	res.end();
});

router.get('/register', function(req,res){
	res.sendFile(path.join(__dirname + '/views/register.html'));
});


router.get('/getuser', getUsersDash);

router.route('/adduser').post(addUser);
router.route('/checkUserExist').get(checkByEmail);
router.route('/checkAndAdd').post(checkAndAdd);



/*
app.get('/users/') // GET all users

app.put('/users/:email') // Create user 

app.get('/users/:email') // Get user by email
*/
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
function clearExpiredTokens(){
	r.db('Capstone').table('Tokens').filter(r.row('expires').lt(r.now().toEpochTime())).delete().run().then(function(result){
		console.log("Clearing Expired Tokens");
		console.log("Expired Tokens Deleted: " + result['deleted']);
	})
}


}