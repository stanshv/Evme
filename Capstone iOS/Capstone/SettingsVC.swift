//
//  SettingsVC.swift
//  Capstone
//
//  Created by Stanley Shvartsberg on 4/2/16.
//  Copyright © 2016 StanleyShvartsberg. All rights reserved.
//


import UIKit

class SettingsVC: UIViewController {
	
	@IBOutlet weak var logOutButton: UIButton!{
		didSet{
			logOutButton.layer.cornerRadius = 8
			logOutButton.layer.borderWidth = 2
			logOutButton.layer.borderColor = UIColor.whiteColor().CGColor
		}
	}

	@IBOutlet weak var imageView: UIImageView!{
		didSet{
			imageView.image = UIImage(named: "EvmeIcon")
			imageView.layer.cornerRadius = 8
			imageView.layer.borderWidth = 2
			imageView.layer.borderColor = UIColor.whiteColor().CGColor
		}
	}

	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
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
	
	//TRIGGERS THE LOGOUT FUNCTION
	@IBAction func logOut(sender: UIButton) {
		logout()
	}
	
	//HTTP DELETE REQUEST THAT WILL EFFECTIVELY LOG A USER OUT
	//WILL DELETE ALL LOCAL USER INFORMATION
	//REQUEST WILL DELETE THE TOKEN ON SERVER HOLDING USER INFORMATION
	//USER WILL HAVE TO LOGIN AGAIN FROM ALL DEVICES ONCE THE TOKEN IS DELETED
	//USER WILL BE MOVED TO THE LOGIN PAGE AND FLAGGED AS UNAUTHORIZED
	func logout(){
		let request = HTTPHelper.helper.buildRequest(ToWhere: "/api/logout", HTTPMethod: "Delete", authType: .Token, contentType: .XWWW)
		HTTPHelper.helper.sendRequest(request){
			error, data in
			if(error != nil){
				print("DATA RECIEVE ERROR=\(error)")
				return
			}
			do{
				let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
				if(json["deleted"]! as! Int == 1){
					print("Logged Out")
					User.USER.loggedIn = false
					User.USER.tokenID = nil
					User.USER.userID = nil
					User.USER.fname = nil
					User.USER.lname = nil
					User.USER.email = nil
					User.USER.karma = nil
					let vc = self.storyboard?.instantiateViewControllerWithIdentifier("LogIn")
					let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
					appDel.window?.rootViewController = vc
					appDel.window?.makeKeyAndVisible()
				}
				else{
					print(json)
				}
				
			} catch {
				print("JSON PARSE ERROR=\(error)")
				return
			}
		}
	}
	
}
