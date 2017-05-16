//
//  HTTPHelper.swift
//  Capstone
//
//  Created by Stanley Shvartsberg on 3/31/16.
//  Copyright © 2016 StanleyShvartsberg. All rights reserved.
//

import Foundation
import UIKit

//TYPE OF AUTHENTICATION REQUESTS
enum HTTPRequestAuthType {
	case None
	case UNPW
	case Token
}

//TYPE OF HTTP CONTENT TYPES
enum HTTPContentType{
	case XWWW
	case Multipart
}

//TYPE OF PICTURES POSSIBLE FOR SENDING
enum PicType{
	case JPG
	case PNG
}

//HELPER CLASS TO BUILD AND SEND HTTP REQUESTS
class HTTPHelper: NSObject, NSURLSessionDelegate {
	
	static let helper = HTTPHelper()
	
	private override init(){}
	
	//let BASE_URL = "https://xanzarcan.com:64875"
	let BASE_URL = "https://xanzarcanicus.ddns.net:64875"
	var boundary : String!
	
	//WILL GENERATE A RANDOM STRING TO BE USED IN A MULTIPART BOUNDARY
	func generateBoundaryString() -> String {
		return "Boundary-\(NSUUID().UUIDString)"
	}
	
	//HELPER FUNCTION TO BUILD A HTTP REQUEST
	//TOWHERE: DICTATES THE PATH OF THE REQUEST BEING VISITED, APPENDED TO BASE_URL STRING
	//METHOD: TYPE OF HTTP METHOD: GET, POST, PUT, DELETE
	//AUTHTYPE: LETS YOU ADD AUTHORIZATIONT TYPES SUCH AS TOKEN AUTHENTICATION
	//CONTENTTYPE: WILL LET YOU DECIDE BETWEEN URLENCODED OR MULTIPART
	//REQUEST IS ONLY BUILT, NOT SENT
	func buildRequest(ToWhere path: String,HTTPMethod method: String, authType: HTTPRequestAuthType, contentType: HTTPContentType) -> NSMutableURLRequest {
		let myURL = NSURL(string: "\(self.BASE_URL)\(path)")
		let request = NSMutableURLRequest(URL: myURL!)
		request.HTTPMethod = method
		
		switch contentType {
		case .Multipart:
			boundary = generateBoundaryString()
			request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
		case .XWWW:
			request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type") //Optional
		}
		
		switch authType{
		case .None:
			break
		case .UNPW:
			let username = "stanshv@gmail.com"
			let password = "abc"
			var basicAuthString = "\(username):\(password)"
			basicAuthString = "Random String"
			let utf8str = basicAuthString.dataUsingEncoding(NSUTF8StringEncoding)
			let base64EncodedString = utf8str?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
			request.addValue("Basic \(base64EncodedString)", forHTTPHeaderField: "Authorization")
		case .Token:
			let token = User.USER.tokenID!
			request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		}
		return request
	}
	
	//HELPER FUNCTION THAT WILL SEND A REQUEST
	//REQUEST: REQUEST THAT IS BUILD USING BUILDREQUEST()
	//COMPLETION: COMPLETION HANDLER, SHOULD BE USED AS TRAILING CLOSURE WITH (ERROR, DATA IN)
	//RESPONSE CONTAINS HEADER INFORMATION
	//DATA WILL CONTAIN BODY INFORMATION
	//IF A 401(UNAUTHORIZED) RESPONSE IS EVER RECEIVED FOR ANY REQUEST THE USER WILL INSTANTLY BE LOGGED OUT LOCALLY
	//USER WILL THEN HAVE TO RE LOG
	func sendRequest(request: NSURLRequest, completion:(NSError!, NSData!) -> Void) -> (){
		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
		let session = NSURLSession(configuration: config, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
		let task = session.dataTaskWithRequest(request) {
			data, response, error in
			if(error != nil){
				completion(error, data)
				print("SEND REQUEST ERROR=\(error)")
				return
			}
			
			if let httpResponse = response as? NSHTTPURLResponse{
				///Everything Is Good
				if(httpResponse.statusCode == 200){
					//print(httpResponse.allHeaderFields)
					completion(nil, data)
				}
				///Unauthorized Error
				else if(httpResponse.statusCode == 401){
					print("UNAUTHORIZED USER")
					UIApplication.sharedApplication().endIgnoringInteractionEvents()
					self.unauthorized()
					return
					//DEBUGGING CODE BELOW
//					let userInfo: [NSObject : AnyObject] =
//					[
//						NSLocalizedDescriptionKey :  NSLocalizedString("Unauthorized", value: "Please Log In", comment: ""),
//						NSLocalizedFailureReasonErrorKey : NSLocalizedString("Unauthorized", value: "Account not logged in", comment: "")
//					]
//					let err = NSError(domain: "HTTPError", code: 401, userInfo: userInfo)
//					
//					print("!!!!!!!  \(data!)")
//					let test = NSString(data: data!, encoding: NSUTF8StringEncoding)
//					print(test)
//					print(test!)
//					var json : NSDictionary!
//					do{
//						json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
//						print("json     \(json)")
//					} catch let error as NSError{
//						print("error     \(error)")
//						print(error.localizedRecoverySuggestion)
//					}
//					print("Unauthorized")
//					completion(nil, data)
				}
				else{
					do{
						if let errorDict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? NSDictionary{
							let responseError : NSError = NSError(domain: "HTTPHelperError", code: httpResponse.statusCode, userInfo: errorDict as? [NSObject : AnyObject])
							print("ERROR1")
							completion(responseError, data)
						}
					}
					catch let error as NSError {
						print("ERROR2")
						if(httpResponse.statusCode==401){
							print("401")
						}
						print("Strange Error Area: \(data)")
						completion(error,data)
					}
				}
				
			}
		}
		task.resume()
	}
	
	//ADDS AND ARRAY OF PARAMATERS TO A MULTIPART BODY
	func addParamsToBody(parameters: [String: String]?, body: NSMutableData){
		func appendString(string: String) {
			let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
			body.appendData(data!)
		}
		if parameters != nil {
			for (key, value) in parameters! {
				appendString("--\(boundary)\r\n")
				appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
				appendString("\(value)\r\n")
			}
		}
	}
	
	//ADDS EITHER A JPG OR PNG TO A MULTIPART BODY
	func addImageToBody(filePathKey:String?,imageName:String,image:UIImage,imageType:PicType,body:NSMutableData){
		func appendString(string: String) {
			let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
			body.appendData(data!)
		}
		var filename = ""
		var mimetype = ""
		var imageData = NSData()
		switch imageType {
		case .JPG:
			imageData = UIImageJPEGRepresentation(image, 0.1)!
			filename = "\(imageName).jpg"
			mimetype = "image/jpg"
		case .PNG:
			imageData = UIImagePNGRepresentation(image)!
			filename = "\(imageName).png"
			mimetype = "image/png"
		}
		appendString("--\(boundary)\r\n")
		appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
		appendString("Content-Type: \(mimetype)\r\n\r\n")
		body.appendData(imageData)
		appendString("\r\n")
	}
	
	//ADDS A JPG TO A MULTIPART BODY
	func addJPGToBody(filePathKey:String?,imageName:String,image:UIImage,compressionQuality:CGFloat,body:NSMutableData){
		func appendString(string: String) {
			let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
			body.appendData(data!)
		}
		let imageData = UIImageJPEGRepresentation(image, compressionQuality)!
		appendString("--\(boundary)\r\n")
		appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(imageName).jpg\"\r\n")
		appendString("Content-Type: image/jpg\r\n\r\n")
		body.appendData(imageData)
		appendString("\r\n")
	}
	
	//REQUIRED TO CLOSE A MULTIPART BODY WITH A BOUNDARY
	func closeMultipartBody(body: NSMutableData){
		body.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
	}
	
	//SETS THE USER TO BE UNAUTHORIZED AND CLEARS OUT ALL DATA AND THEN RETURNS TO THE LOGIN SCREEN
	func unauthorized(){
		User.USER.loggedIn = false
		User.USER.tokenID = nil
		User.USER.userID = nil
		User.USER.fname = nil
		User.USER.lname = nil
		User.USER.email = nil
		User.USER.karma = nil
		let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
		let vc = appDel.mainStoryBoard.instantiateViewControllerWithIdentifier("LogIn")
		appDel.window?.rootViewController = vc
		appDel.window?.makeKeyAndVisible()
		AlertHelper.helper.alertMe(
			alertTitle: "Bad Token"
			, messageToShow: "Uh Oh, looks like you arent logged in anymore"
			, actionTitle: "Ok, I'll Log In Again"
			, fromController: vc
		)
	}

	
	//LETS THE APPLICATION ACCEPT UNTRUSTED SSL SIGNING, USED BECAUSE MY SERVER IS SELF SIGNED
	func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
		completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
	}
	
}
