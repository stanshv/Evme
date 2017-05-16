//
//  User.swift
//  Capstone
//
//  Created by Stanley Shvartsberg on 4/25/16.
//  Copyright © 2016 StanleyShvartsberg. All rights reserved.
//

import Foundation
import UIKit

//CLASS TO MANAGE USER INFORMATION LOCALLY
class User: NSObject{
	
	static let USER = User()
	private override init(){}
	
	/////////////////////////////////////////////////////////////////////////////////////
	//User Logged In Or Not
	/////////////////////////////////////////////////////////////////////////////////////
	var loggedIn: Bool?{
		get{
			return NSUserDefaults.standardUserDefaults().boolForKey("isLoggedIn")
		}
		set{
			if(newValue == nil){
				NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isLoggedIn")
				return
			}
			NSUserDefaults.standardUserDefaults().setBool(newValue!, forKey: "isLoggedIn")
		}
	}

	/////////////////////////////////////////////////////////////////////////////////////
	//Profile Picture
	/////////////////////////////////////////////////////////////////////////////////////
	var profilePic: UIImage?{
		get{
			let picname = "\(userID!)profilepic"
			if(picname=="ERRORprofilepic"){
				return UIImage(named: "defaultuser")!
			}
			let path = fileInDocumentsDirectory(picname)
			let myPic = loadImageFromPath(path)
			if(myPic == nil){
				return UIImage(named: "defaultuser")!
			}
			return myPic
		}
		set{
			let picname = "\(userID!)profilepic"
			let path = fileInDocumentsDirectory(picname)
			if(newValue == nil){
				saveImage(UIImage(named: "defaultuser")!, path: path)
				return
			}
			saveImage(newValue!, path: path)
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////////////
	//User ID
	/////////////////////////////////////////////////////////////////////////////////////
	var userID: String?{
		get{
			return NSUserDefaults.standardUserDefaults().stringForKey("userID") ?? "ERROR"
		}
		set{
			if(newValue == nil){
				NSUserDefaults.standardUserDefaults().removeObjectForKey("userID")
				return
			}
			NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "userID")
		}
	}
	
	
	/////////////////////////////////////////////////////////////////////////////////////
	//User Logged In Or Not
	/////////////////////////////////////////////////////////////////////////////////////
	var email: String?{
		get{
			return NSUserDefaults.standardUserDefaults().stringForKey("email") ?? "ERROR"
		}
		set{
			if(newValue == nil){
				NSUserDefaults.standardUserDefaults().removeObjectForKey("email")
				return
			}
			NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "email")
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////////////
	//User First Name
	/////////////////////////////////////////////////////////////////////////////////////
	var fname: String?{
		get{
			return NSUserDefaults.standardUserDefaults().stringForKey("fname") ?? "ERROR"
		}
		set{
			if(newValue == nil){
				NSUserDefaults.standardUserDefaults().removeObjectForKey("fname")
				return
			}
			NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "fname")
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////////////
	//User Last Name
	/////////////////////////////////////////////////////////////////////////////////////
	var lname: String?{
		get{
			return NSUserDefaults.standardUserDefaults().stringForKey("lname") ?? "ERROR"
		}
		set{
			if(newValue == nil){
				NSUserDefaults.standardUserDefaults().removeObjectForKey("lname")
				return
			}
			NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "lname")
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////////////
	//User Karma Points
	/////////////////////////////////////////////////////////////////////////////////////
	var karma: Int?{
		get{
			return NSUserDefaults.standardUserDefaults().integerForKey("karma")
		}
		set{
			if(newValue == nil){
				NSUserDefaults.standardUserDefaults().removeObjectForKey("karma")
				return
			}
			NSUserDefaults.standardUserDefaults().setInteger(newValue!, forKey: "karma")
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////////////
	//Authentication Token
	/////////////////////////////////////////////////////////////////////////////////////
	var tokenID : String?{
		get{
			return NSUserDefaults.standardUserDefaults().stringForKey("tokenID") ?? "ERROR"
		}
		set{
			if(newValue == nil){
				NSUserDefaults.standardUserDefaults().removeObjectForKey("tokenID")
				return
			}
			NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "tokenID")
		}
	}
	/////////////////////////////////////////////////////////////////////////////////////
	//Authentication Token Expires Time
	/////////////////////////////////////////////////////////////////////////////////////
	var tokenExpires : Double?{
		get{
			return NSUserDefaults.standardUserDefaults().doubleForKey("tokenExpires")
		}
		set{
			if(newValue == nil){
				NSUserDefaults.standardUserDefaults().removeObjectForKey("tokenExpires")
				return
			}
			NSUserDefaults.standardUserDefaults().setDouble(newValue!, forKey: "tokenExpires")
		}
	}
	
	
	// Define the specific path, image name
	//let imagePath = fileInDocumentsDirectory(myProfilePic)

	//GETS THE PATH OF USERS DOCUMENT DIRECTORY
	func getDocumentsURL() -> NSURL {
		let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
		return documentsURL
	}
 
	//GETS PATH OF DOCUMENT
	func fileInDocumentsDirectory(filename: String) -> String {
		let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
		return fileURL.path!
	}
	
	//RETRIEVES AND IMAGE FROM A PATH IN THE DOCUMENT DIRECTORY
	func loadImageFromPath(path: String) -> UIImage? {
		
		let image = UIImage(contentsOfFile: path)
		
		if image == nil {
			
			print("missing image at: \(path)")
		}
		print("Loading image from path: \(path)") // this is just for you to see the path in case you want to go to the directory, using Finder.
		return image
		
	}
	
	//SAVES AN IMAGE TO THE DOCUMENT DIRECTORY
	func saveImage (image: UIImage, path: String ) -> Bool{
		
		//let pngImageData = UIImagePNGRepresentation(image)
		let jpgImageData = UIImageJPEGRepresentation(image, 1.0)   // if you want to save as JPEG
		let result = jpgImageData!.writeToFile(path, atomically: true)
		
		return result
		
	}
	
	//SENDS A REQUEST TO THE SERVER TO DOWNLOAD A USERS PROFILE PICTURE
	func loadProfilePicFromDatabase(){
		let request = HTTPHelper.helper.buildRequest(ToWhere: "/api/getProfilePic/\(userID!)", HTTPMethod: "GET", authType: .Token, contentType: .XWWW)
		HTTPHelper.helper.sendRequest(request){
			error, data in
			if(error != nil){
				print("DATA RECIEVE ERROR=\(error)")
				return
			}
			if let myDatabasePic = UIImage(data: data){
				print("loaded pic from database")
				self.profilePic = myDatabasePic
			}
			else{
				print("loaded default pic")
				self.profilePic = UIImage(named: "defaultuser")!
			}
		}
	}
	
	//SAVES A USERS PROFILE PICTURE TO THE DATABASE
	func saveProfilePicToDatabase(){
		let request = HTTPHelper.helper.buildRequest(ToWhere: "/api/setProfilePic", HTTPMethod: "Post", authType: .Token, contentType: .Multipart)
		let params = [
			"userID":userID!
		]
		let image = profilePic
		let requestBody = NSMutableData();
		HTTPHelper.helper.addParamsToBody(params, body: requestBody)
		HTTPHelper.helper.addJPGToBody("profilePictureUpload", imageName: "highQuality", image: image!, compressionQuality: 0.65, body: requestBody)
		HTTPHelper.helper.addJPGToBody("profilePictureUpload", imageName: "lowQuality", image: image!, compressionQuality: 0.05, body: requestBody)
		HTTPHelper.helper.closeMultipartBody(requestBody)
		request.HTTPBody = requestBody
		
		HTTPHelper.helper.sendRequest(request){
			error, data in
			if(error != nil){
				print("DATA RECIEVE ERROR=\(error)")
				return
			}
			do{
				let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
				guard let insertedRecord = json["inserted"] else {
					return
				}
				if(insertedRecord as! Int != 0){
					print("something happened0")
				}
				else{
					return
				}
			} catch {
				print("JSON PARSE ERROR=\(error)")
				return
			}
		}
	}
	
	
	
}