

module.exports = function(router,passport,r){


/////////////	USED FOR REGISTERING & LOGGING IN
	router.put('/APILogin', logInGetToken);
	router.put('/APIRegister', checkAndAdd);

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

	function logInGetToken(req, res){
		console.log("Logged In");
		var email = req.body.email;
		var pass = req.body.pass;
		//add .pluck
		r.db('Capstone').table('Users4').getAll(email, {index: 'email'}).run().then(function(result){
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

	function checkAndAdd(req, res){
		console.log("Check And Add");
		var fname = req.body.fname;
		var lname = req.body.lname;
		var email = req.body.email;
		var pass = req.body.pass;
		r.branch(
			r.db('Capstone').table('Users4').getAll(email, {index: 'email'}).count().gt(0),
  			{"doesit":true},
 			r.db('Capstone').table('Users4').insert({fname:fname,lname:lname,email:email,pass:pass})
		).run().then(function(result){
			console.log(result);
			res.end(JSON.stringify(result, null, 2));
		});
		
	}
}

