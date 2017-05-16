//
//  AlertHelper.swift
//  Capstone
//
//  Created by Stanley Shvartsberg on 3/31/16.
//  Copyright © 2016 StanleyShvartsberg. All rights reserved.
//

import Foundation
import UIKit

//USED TO DISPLAY ALERTS THROUGHOUT THE PROJECT
class AlertHelper : NSObject{
	
	//CREATES STATIC OBJECT OF THIS CLASS TO BE USED THROUGHOUT PROJECT
	static let helper = AlertHelper()
	
	//PREVENTS MORE THAN ONE OBJECT FROM BEING CREATED
	private override init(){}
	
	//WILL CREATE A BASIC ALERT
	func alertMe(alertTitle alertTitle:String,  messageToShow: String, actionTitle:String, fromController: UIViewController) {
		let alert = UIAlertController(title: alertTitle,message: messageToShow,	preferredStyle: .Alert)
		let gotIt = UIAlertAction(title: actionTitle, style: .Default, handler: nil)
		alert.addAction(gotIt)
		fromController.presentViewController(alert, animated: true, completion: nil)
	}
	
	//WILL CREATE A BASIC ALERT WITH COMPLETION HANDLER WHEN THE OK BUTTON IS PRESSED
	func alertMeWithOKComplete(alertTitle alertTitle:String,  messageToShow: String, actionTitle:String, fromController: UIViewController, completion: (UIAlertAction) -> Void) {
		let alert = UIAlertController(title: alertTitle,message: messageToShow,	preferredStyle: .Alert)
		let gotIt = UIAlertAction(title: actionTitle, style: .Default, handler: completion)
		alert.addAction(gotIt)
		fromController.presentViewController(alert, animated: true, completion: nil)
	}
	
	//WILL CREATE A BASIC ALERT AND SEGUE TO A NEW WINDOW WHEN THE OK BUTTON IS PRESSED
	func alertMeToNewWindow(alertTitle alertTitle:String,  messageToShow: String, actionTitle:String, fromController: UIViewController, toControllerStoryboardID: String) {
		let alert = UIAlertController(title: alertTitle,message: messageToShow,	preferredStyle: .Alert)
		let gotIt = UIAlertAction(title: actionTitle, style: .Default){ action in
			self.goToViewController(toControllerStoryboardID)
		}
		alert.addAction(gotIt)
		fromController.presentViewController(alert, animated: true, completion: nil)
		
	}
	
	//WILL CREATE A BASIC ALERT FROM THE ROOT VIEW CONTROLLER
	func rootAlertMe(alertTitle alertTitle:String,  messageToShow: String, actionTitle:String) {
		let alert = UIAlertController(title: alertTitle,message: messageToShow,	preferredStyle: .Alert)
		let gotIt = UIAlertAction(title: actionTitle, style: .Default, handler: nil)
		alert.addAction(gotIt)
		UIApplication.sharedApplication().keyWindow?.rootViewController!.presentViewController(alert, animated: true, completion: nil)
	}
	
	func goToViewController(storyBoardID: String){
		let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
		let vc = appDel.mainStoryBoard.instantiateViewControllerWithIdentifier(storyBoardID)
		appDel.window?.rootViewController = vc
		appDel.window?.makeKeyAndVisible()

	}
}