var BearerStrategy   = require('passport-http-bearer').Strategy;

//PASSPORT AUTHENTICATION STRATEGIES GO HERE, SUCH AS LOCAL, BASIC, FACEBOOK, ETC...
module.exports = function(passport,r) {

	// // NOT CURRENTLY BEING USED
	// passport.serializeUser(function(user, done){
	// 	done(null, user.id);
	// });

	// // NOT CURRENTLY BEING USED
	// passport.deserializeUser(function(id, done){
	// 	//query DB here, below is temp code
	// 	done(null, {id: id, name: id});
	// });

	//PASSPORT STRATEGY FOR BEARER TOKENS
	passport.use(new BearerStrategy(function(token, done){
		r.db('Capstone').table('Tokens').get(token).run().then(function(result){
			if(result){
				//IF TOKEN EXISTS AND IS MATCHED, USERID IS RETURNED
				done(null, result);			
			}
			else{
				//IF TOKEN DOESNT EXIST, FALSE IS RETURNED
			 	done(null, false);
			}
		});
	}));

	// // NOT CURRENTLY BEING USED
	// function verifyCred(username, password, done){
	// 	//generic testing implementation
	// 	if(username == password){
	// 		done(null,{id: username, name: username});
	// 	}
	// 	else{
	// 		done(null,null);
	// 	}

	// }

}