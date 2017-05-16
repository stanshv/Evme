
module.exports = function(router,passport,r){


//REQUIRES ALL CALLS TO PASS TOKEN AUTHENTICATION
router.use(passport.authenticate('bearer', { session: false }));
//router.use('/data', passport.authenticate('bearer', { session: false }));


//TEST DATA
router.get('/data', function(req,res){
	res.json([
		{value: "foo"},
		{value: "bar"},
		{value: "you"},
	])
});

//TEST CALL GETS ALL USERS IN A TABLE
router.get('/getUserDash', getUsersDash);

//CALLS FROM CLIENT
/////////////////////////////////////////////////////////////////////////////////////////////////////////

//MANUALLY CLEAR EXPIRED TOKENS
router.get('/clearTokens', clearExpiredTokens);

//LOGS THE USER OUT BY DELETING ASSOCIATED TOKEN
router.delete('/logout', logOut);

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

function logOut(req, res){
	console.log("Logged Out");
	var token = req.body.token;
	r.db('Capstone').table('Tokens').get(token).delete().run().then(function(result){
		res.redirect('/login');
	});
}

function getUsersDash(req, res){
	r.db('Capstone').table('Users4').run().then(function(result) {
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