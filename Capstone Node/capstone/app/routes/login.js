

module.exports = function(router,passport,r){


/////////////	USED FOR LOGGING IN
	router.put('/APILogin', logInGetToken);

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


}

