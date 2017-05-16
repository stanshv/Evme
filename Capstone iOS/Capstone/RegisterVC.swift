//
//  RegisterViewController.swift
//  Capstone
//
//  Created by Stanley Shvartsberg on 3/2/16.
//  Copyright © 2016 StanleyShvartsberg. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController {

	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var pass2Text: UITextField!
	@IBOutlet weak var passText: UITextField!
	@IBOutlet weak var emailText: UITextField!
	@IBOutlet weak var fnameText: UITextField!
	@IBOutlet weak var lnameText: UITextField!
	@IBOutlet weak var phoneText: UITextField!
	@IBOutlet weak var registerButton: UIButton!{
		didSet{
			registerButton.layer.cornerRadius = 8
			registerButton.layer.borderWidth = 2
			registerButton.layer.borderColor = UIColor.whiteColor().CGColor
		}
	}

	@IBOutlet weak var goBackButton: UIButton!{
		didSet{
			goBackButton.layer.cornerRadius = 8
			goBackButton.layer.borderWidth = 2
			goBackButton.layer.borderColor = UIColor.whiteColor().CGColor
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
	
	//CHECKS THAT AN EMAIL IS IN PROPER EMAIL FORMAT AAA@BBB.CCC
	func validateEmail(enteredEmail:String) -> Bool {
		let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
		return emailPredicate.evaluateWithObject(enteredEmail)
	}
	
	//CHECKS THAT ALL FIELDS ARE ENTERED, PASSWORDS MATCH, AND EMAIL IS PROPER
	//REGISTERS ACCOUNT
	@IBAction func registerAccount(sender: UIButton) {
		let email = emailText.text!
		let pass = passText.text!
		let pass2 = pass2Text.text!
		let fname = fnameText.text!
		let lname = lnameText.text!
		let phone = phoneText.text!
		if(email.isEmpty || pass.isEmpty || pass2.isEmpty || fname.isEmpty || lname.isEmpty || phone.isEmpty){
			AlertHelper.helper.alertMe(alertTitle: "Whoops", messageToShow: "There Is An Empty Field", actionTitle: "Oh, Ok", fromController: self)
			return
		}
		if(!validateEmail(email)){
			AlertHelper.helper.alertMe(alertTitle: "Whoops", messageToShow: "Invalid Email", actionTitle: "Did I Forget The Pesky @?", fromController: self)
			return
		}
		if(pass != pass2){
			AlertHelper.helper.alertMe(alertTitle: "Whoops", messageToShow: "Passwords Don't Match", actionTitle: "Oh No!", fromController: self)
			return
		}
		view.endEditing(true)
		register(firstName: fname, lastName: lname, email: email, pass: pass, phone:phone)

	}
	

	//HTTP PUT REQUEST THAT WILL CREATE A NEW ACCOUNT IF EMAIL DOES NOT EXIST, WILL RETURN MESSAGE IF IT DOES
	//IF USER IS CREATED, SERVER WILL RETURN JSON OBJECT OF RESULTS
	//IF USER EXISTS, A NOTIFICATION WILL OCCUR STATING THE USER EXISTS ALREADY
	func register(firstName firstName: String, lastName: String, email: String, pass: String, phone: String){
		startThinking()
		let request = HTTPHelper.helper.buildRequest(ToWhere: "/account/APIRegister", HTTPMethod: "Put", authType: .None, contentType: .XWWW)
		let bodyString = "email=\(email)&pass=\(pass)&fname=\(firstName)&lname=\(lastName)&phone=\(phone)"
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
				print(json)
				if(json["inserted"] as! Int == 1){
					print("User Created")
					self.stopThinking()
					AlertHelper.helper.alertMe(alertTitle: "Hooray!", messageToShow: "You've Been Registered", actionTitle: "YAY!", fromController: self)
					let vc = self.storyboard?.instantiateViewControllerWithIdentifier("LogIn")
					let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
					NSOperationQueue.mainQueue().addOperationWithBlock {
						appDel.window?.rootViewController = vc
						appDel.window?.makeKeyAndVisible()
					}
				}
				else if(json["inserted"] as! Int == -1){
					print("User Exists")
					self.stopThinking()
					AlertHelper.helper.alertMe(alertTitle: "Whoops!", messageToShow: "Email exists", actionTitle: "Oh?", fromController: self)
				}
				else{
					print("Something Went Wrong")
					self.stopThinking()
					AlertHelper.helper.alertMe(alertTitle: "Whoops!", messageToShow: "Something Went Wrong", actionTitle: "Got It", fromController: self)
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
