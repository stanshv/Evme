//
//  ProfileVC.swift
//  Capstone
//
//  Created by Stanley Shvartsberg on 3/16/16.
//  Copyright © 2016 StanleyShvartsberg. All rights reserved.
//

import UIKit

//VIEW CONTROLLER FOR PROFILE PAGE
class ProfileVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	@IBOutlet weak var imageView: UIImageView!
	
	var myImage : UIImage!

	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var karmaLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var emailLabel: UILabel!
	@IBOutlet weak var takePicture: UIButton!{
		didSet{
			takePicture.layer.cornerRadius = takePicture.bounds.size.width / 2
			takePicture.layer.masksToBounds = false
			takePicture.clipsToBounds = true
		}
	}
	@IBOutlet weak var useExistingPicture: UIButton!{
		didSet{
			useExistingPicture.layer.cornerRadius = useExistingPicture.bounds.size.width / 2
			useExistingPicture.layer.masksToBounds = false
			useExistingPicture.clipsToBounds = true
		}
	}

	@IBOutlet weak var seenMeButton: UIButton!{
		didSet{
			seenMeButton.layer.cornerRadius = 8
			seenMeButton.layer.borderWidth = 2
			seenMeButton.layer.borderColor = UIColor.whiteColor().CGColor
		}
	}

	
	@IBOutlet weak var iveSeenButton: UIButton!{
		didSet{
			iveSeenButton.layer.cornerRadius = 8
			iveSeenButton.layer.borderWidth = 2
			iveSeenButton.layer.borderColor = UIColor.whiteColor().CGColor
		}
	}

	@IBOutlet weak var coverView: UIView!
	var segueData : [NSDictionary] = []
	var imagePicker: UIImagePickerController!
	var newMedia: Bool?
	
	//UPDATES KARMA SCORE EVERYTIME VIEW APPEARS
	override func viewDidAppear(animated: Bool) {
		updateKarma()
	}
	
	//WHEN THE VIEW LOADS LABELS AND PICTUREVIEWS WILL BE POPULATED
	override func viewDidLoad() {
		super.viewDidLoad()
		imageView.image = User.USER.profilePic
		let karma = User.USER.karma!
		let fname = User.USER.fname!
		let lname = User.USER.lname!
		let email = User.USER.email!
		karmaLabel.text = "Karma: \(karma)"
		nameLabel.text = "\(fname) \(lname)"
		emailLabel.text = "\(email)"
		// Do any additional setup after loading the view.
	}
	
	//CONTROLLS SEGUE PREPERATION
	//PASSES TABLE DATA TO THE THE NEXT VIEW CONTROLLER: HISTORY TABLE PAGE
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		guard let button = sender as? UIButton else{
			print("didnt cast")
			return
		}
		if(button == seenMeButton){
			//print("seen me")
		}
		else{
			//print("ive seen")
		}
		let nextVC = (segue.destinationViewController as! HistoryTableVC)
		nextVC.tableData = segueData
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
	
	//REQUESTS POSTS MADE ABOUT THE USER
	@IBAction func seenMe(sender: UIButton) {
		getPostsMadeAboutMe()
	}
	
	//REQUESTS POSTS USER HAS MADE
	@IBAction func iveSeen(sender: AnyObject) {
		getPostsIveMade()
	}
	
	//CHANGE PROFILE PICTURE WITH ONE FROM USERS ALBUM
	@IBAction func existingPictureButton(sender: AnyObject) {
		useAlbumPic()
	}
	
	//CHANGE PROFILE PICTURE USING THE CAMERA
	@IBAction func takePictureButton(sender: AnyObject) {
		takePic()
	}
	
	//HTTP GET REQUEST TO RETRIEVE ALL POSTS MADE ABOUT USER
	//DATA RECEIVED WILL BE AN ARRAY OF DICTIONARIES CONTAINING LIMITED POST DATA
	func getPostsMadeAboutMe(){
		startThinking()
		let request = HTTPHelper.helper.buildRequest(ToWhere: "/api/getPostsMadeAboutMe", HTTPMethod: "GET", authType: .Token, contentType: .XWWW)
		HTTPHelper.helper.sendRequest(request){
			error, data in
			if(error != nil){
				print("DATA RECIEVE ERROR=\(error)")
				self.stopThinking()
				AlertHelper.helper.alertMe(alertTitle: "Whoops!", messageToShow: "Something Went Wrong", actionTitle: "Got It", fromController: self)
				return
			}
			do{
				let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! [NSDictionary]
				self.segueData = json
				self.stopThinking()
				self.performSegueWithIdentifier("SHOWHISTORY", sender: self.seenMeButton)
			} catch {
				print("JSON PARSE ERROR=\(error)")
				AlertHelper.helper.alertMe(alertTitle: "Oh No", messageToShow: "Something Happened!", actionTitle: "I'll Try Again", fromController: self)
				self.stopThinking()
				return
			}
		}
	}
	
	//HTTP GET REQUEST TO RETRIEVE ALL POSTS THAT THE USER MADE ABOUT SOMEONE ELSE
	//DATA RECEIVED WILL BE AN ARRAY OF DICTIONARIES CONTAINING LIMITED POST DATA
	func getPostsIveMade(){
		startThinking()
		let request = HTTPHelper.helper.buildRequest(ToWhere: "/api/getPostsIveMade", HTTPMethod: "GET", authType: .Token, contentType: .XWWW)
		HTTPHelper.helper.sendRequest(request){
			error, data in
			if(error != nil){
				print("DATA RECIEVE ERROR=\(error)")
				self.stopThinking()
				AlertHelper.helper.alertMe(alertTitle: "Whoops!", messageToShow: "Something Went Wrong", actionTitle: "Got It", fromController: self)
				return
			}
			do{
				let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! [NSDictionary]
				self.segueData = json
				self.stopThinking()
				self.performSegueWithIdentifier("SHOWHISTORY", sender: self.iveSeenButton)
			} catch {
				print("JSON PARSE ERROR=\(error)")
				AlertHelper.helper.alertMe(alertTitle: "Oh No", messageToShow: "Something Happened!", actionTitle: "I'll Try Again", fromController: self)
				self.stopThinking()
				return
			}
		}
	}
	
	//BRINGS UP THE PICTURE PICKER FOR TAKING A PICTURE
	func takePic(){
		if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
			if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
				imagePicker =  UIImagePickerController()
				imagePicker.delegate = self
				imagePicker.allowsEditing = true
				imagePicker.sourceType = .Camera
				imagePicker.cameraCaptureMode = .Photo
				presentViewController(imagePicker, animated: true, completion: nil)
			} else {
				print("no rear camera")
			}
		} else {
			print("cant use cam")
		}
	}
	
	//LETS YOU CHOOSE A PICTURE FROM USERS PHOTO ALBUM
	//ONLY SQUARE PICTURES ARE ALLOWED FOR PROFILE PICTURES
	//EDITOR WILL MAKE YOU CROP A PICTURE TO SQUARE
	func useAlbumPic(){
		imagePicker =  UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.allowsEditing = true
		imagePicker.sourceType = .PhotoLibrary
		presentViewController(imagePicker, animated: true, completion: nil)
	}
	
	//DICTATES WHAT HAPPENS WHEN A PICTURE IS SELECTED
	//ONLY SQUARE PICTURES ARE ALLOWED FOR PROFILE PICTURES
	//EDITOR WILL MAKE YOU CROP A PICTURE TO SQUARE
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
			imageView.image = pickedImage
			User.USER.profilePic = pickedImage
			User.USER.saveProfilePicToDatabase()
		}
		dismissViewControllerAnimated(true, completion: {})
	}
	
	//WHAT HAPPENS WHEN USER CANCELS HAVING A PICTURE
	func imagePickerControllerDidCancel(picker: UIImagePickerController) {
		print("User canceled image")
		dismissViewControllerAnimated(true, completion: {})
	}
	
	//HTTP GET REQUEST TO REFRESH KARMA SCORE OF THE USER
	//A STRING WILL BE RETURNED CONTAINING THE NEW KARMA SCORE
	func updateKarma(){
		let request = HTTPHelper.helper.buildRequest(ToWhere: "/api/getKarmaPoints", HTTPMethod: "GET", authType: .Token, contentType: .XWWW)
		HTTPHelper.helper.sendRequest(request){
			error, data in
			if(error != nil){
				print("DATA RECIEVE ERROR=\(error)")
				return
			}
			let response = NSString(data: data!, encoding: NSUTF8StringEncoding)!
			//print(response)
		}
	}
	
}
