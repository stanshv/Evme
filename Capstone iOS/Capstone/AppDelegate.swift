//
//  AppDelegate.swift
//  Capstone
//
//  Created by Stanley Shvartsberg on 2/10/16.
//  Copyright © 2016 StanleyShvartsberg. All rights reserved.
//

import UIKit
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		let isLoggedIn: Bool = User.USER.loggedIn!
		//ANYTIME THE APPLICATION LAUNCHES A LOG IN CHECK IS PERFORMED
		if(isLoggedIn == false){
			let loginViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("LogIn") as! LogInVC
			window!.rootViewController = loginViewController
			window!.makeKeyAndVisible()
		}
		else{
			let launchPage = mainStoryBoard.instantiateViewControllerWithIdentifier("TabBarController")
			window!.rootViewController = launchPage
			window!.makeKeyAndVisible()
		}
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		
		checkLoggedIn()
		
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	//HTTP GET REQUEST TO CHECK IF THE USERS LOCALLY STORED TOKEN EXISTS
	//IF THE TOKEN EXISTS THEN THE USER IS PROPERLLY LOGGED IN
	//IF TOKEN DOESNT EXIST THEN USER IS UNAUTHORIZED, ALL LOCAL DATA IS ERASED AND USER IS RETURNED TO LOGIN PAGE
	func checkLoggedIn(){
		let request = HTTPHelper.helper.buildRequest(ToWhere: "/api/tokenCheck", HTTPMethod: "GET", authType: .Token, contentType: .XWWW)
		HTTPHelper.helper.sendRequest(request){
			error, data in
			if(error != nil){
				print("DATA RECIEVE ERROR=\(error)")
				return
			}
			let response = NSString(data: data!, encoding: NSUTF8StringEncoding)!
			if(response != "valid"){
				User.USER.loggedIn = false
				User.USER.tokenID = nil
				User.USER.userID = nil
				User.USER.fname = nil
				User.USER.lname = nil
				User.USER.email = nil
				User.USER.karma = nil
				let vc = self.mainStoryBoard.instantiateViewControllerWithIdentifier("LogIn")
				self.window!.rootViewController = vc
				self.window!.makeKeyAndVisible()
				AlertHelper.helper.alertMe(
					alertTitle: "Bad Token"
					, messageToShow: "Uh Oh, looks like you arent logged in anymore"
					, actionTitle: "Ok, I'll Log In Again"
					, fromController: vc
				)
			}
		}
	}
}

