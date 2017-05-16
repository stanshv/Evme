//
//  LogInVC.swift
//  Capstone
//
//  Created by Stanley Shvartsberg on 3/1/16.
//  Copyright © 2016 StanleyShvartsberg. All rights reserved.
//

import UIKit

class LogInVC: UIViewController {
	
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var emailText: UITextField!
	@IBOutlet weak var passText: UITextField!
	@IBOutlet weak var logInButton: UIButton!{
		didSet{
			logInButton.layer.cornerRadius = 8
			logInButton.layer.borderWidth = 2
			logInButton.layer.borderColor = UIColor.whiteColor().CGColor
		}
	}
	@IBOutlet weak var registerButton: UIButton!{
		didSet{
			registerButton.layer.cornerRadius = 8
			registerButton.layer.borderWidth = 2
			registerButton.layer.borderColor = UIColor.whiteColor().CGColor
		}
	}

	@IBOutlet weak var coverView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	//DISMISSES THE KEYBOARD WHEN TOUCHES OUTSIDE KEYBOARD ARE DETECTED
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
		view.endEditing(true)
		super.touchesBegan(touches, withEvent: event)
	}
	
	//CONTROLS PROPERTIES IN THE VIEW CONTROLLER THAT SHOW APP IS "THINKING"
	//DISABLES USER INTERACTION TO PREVENT HUMAN ERROR
	func startThinking(){
		coverView.hidden = false
		activityIndicator.startAnimating()
		UIApplication.sharedApplication().beginIgnoringInteractionEvents()
	}
	
	//ENDS "THINKING"
	//ENABLES USER INTERACTION AGAIN
	func stopThinking(){
		coverView.hidden = true
		activityIndicator.stopAnimating()
		UIApplication.sharedApplication().endIgnoringInteractionEvents()
	}
	
	//CHECKS THAT ALL FIELDS ARE FILLED IN AND CALLES THE LOGIN FUNCTION
	@IBAction func logIn(sender: UIButton) {
		let email = emailText.text!
		let pass = passText.text!
		if(email.isEmpty || pass.isEmpty){
			AlertHelper.helper.alertMe(alertTitle: "Oops!", messageToShow: "You Did Not Fill In The Fields", actionTitle: "Okie Dokes", fromController: self)
			return
		}
		view.endEditing(true)
		loginFunc(email, pass: pass)
	}
	
	//HTTP PUT REQUEST THAT WILL LOG A USER IN
	//IF A USER SUCCESFULLY LOGS IN THEY WILL RECIEVE A TOKEN FOR ALL FURTHER COMMUNICATIONS WITH THE SERVER
	//AN APPROPRIATE ERROR MESSAGE WILL DISPLAYED IF USERNAME OR PASSWORD IS INCORRECT
	//USERNAME AND PASSWORD SHOULD ONLY BE TRANSMITTED VIA AN ENCRYPTED CONNECTION
	func loginFunc(email: String, pass: String){
		startThinking()
		let request = HTTPHelper.helper.buildRequest(ToWhere: "/account/APILogin", HTTPMethod: "PUT", authType: .None, contentType: .XWWW)
		let bodyString = "email=\(email)&pass=\(pass)"
		request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding)
		HTTPHelper.helper.sendRequest(request){
			error, data in
			if(error != nil){
				print("DATA RECIEVE ERROR=\(error)")
				self.stopThinking()
				AlertHelper.helper.alertMe(alertTitle: "Whoops!", messageToShow: "Something Went Wrong", actionTitle: "Got It", fromController: self)
				return
			}
			do{
				let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
				if((json["typeOfLogin"]) != nil){
					print("Type Of Login Is: \(json["typeOfLogin"]!)")
					//print("TOKEN IS: \(json["token"]!)")
					//print("USERID IS: \(json["userID"]!)")
					User.USER.loggedIn = true
					User.USER.tokenID = json["token"]! as? String
					User.USER.userID = json["userID"]! as? String
					User.USER.fname = json["fname"]! as? String
					User.USER.lname = json["lname"]! as? String
					User.USER.email = json["email"]! as? String
					User.USER.karma = json["karma"]! as? Int
					User.USER.loadProfilePicFromDatabase()
					self.stopThinking()
					let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController")
					let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
					NSOperationQueue.mainQueue().addOperationWithBlock {
						appDel.window?.rootViewController = vc
						appDel.window?.makeKeyAndVisible()
					}
				}
				else{
					print(json["error"]!)
					self.stopThinking()
					AlertHelper.helper.alertMe(alertTitle: "Whoops!", messageToShow: "Wrong \(json["error"]!)", actionTitle: "Got It", fromController: self)
				}
			} catch {
				self.stopThinking()
				AlertHelper.helper.alertMe(alertTitle: "Oh No!", messageToShow: "Something Went Wrong.", actionTitle: "Ok ☹️", fromController: self)
				print("JSON PARSE ERROR=\(error)")
				return
			}
		}
	}
	

}
