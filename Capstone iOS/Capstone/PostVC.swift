//
//  PostVC.swift
//  Capstone
//
//  Created by Stanley Shvartsberg on 4/4/16.
//  Copyright © 2016 StanleyShvartsberg. All rights reserved.
//

import UIKit
import MapKit

//VIEW CONTROLLER TO HANDLE NEW POSTS
class PostVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{

	
	
	@IBOutlet weak var coverView: UIView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var removePicture: UIButton!{
		didSet{
			removePicture.layer.cornerRadius = removePicture.bounds.size.width / 2
			removePicture.layer.masksToBounds = false
			removePicture.clipsToBounds = true
		}
	}
	
	
	@IBOutlet weak var leftImageView: UIImageView!
	
	@IBOutlet weak var postButton: UIButton!{
		didSet{
			postButton.layer.cornerRadius = 8
			postButton.layer.borderWidth = 2
			postButton.layer.borderColor = UIColor.whiteColor().CGColor
		}
	}

	
	@IBOutlet weak var leftUserView: UIImageView!{
		didSet{
			leftUserView.image = User.USER.profilePic
			leftUserView.layer.borderWidth = 2.0
			leftUserView.layer.masksToBounds = false
			leftUserView.layer.borderColor = UIColor.blackColor().CGColor
			leftUserView.layer.cornerRadius = leftUserView.frame.size.height/2
			leftUserView.clipsToBounds = true
		}
	}
	
	@IBOutlet weak var rightUserView: UIImageView!{
		didSet{
			if let unwrappedImage = leftImage{
				rightUserView.image = unwrappedImage
				rightUserView.layer.borderWidth = 2.0
				rightUserView.layer.masksToBounds = false
				rightUserView.layer.borderColor = UIColor.blackColor().CGColor
				rightUserView.layer.cornerRadius = rightUserView.frame.size.height/2
				rightUserView.clipsToBounds = true
			}
		}
	}
	
	@IBOutlet weak var mapView: MKMapView!{
		didSet{
			let center = CLLocationCoordinate2D(latitude: coordinates!.latitude, longitude: coordinates!.longitude)
			let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
			self.mapView.setRegion(region, animated: true)
			let pin = MapPin(coordinate: coordinates!)
			self.mapView.addAnnotation(pin)
		}
	}
	
	@IBOutlet weak var nameLabel: UILabel!{
		didSet{
			if let unwrappedName = name{
				nameLabel.text = unwrappedName
			}
			
		}
	}
	
	@IBOutlet weak var timeLabel: UILabel!{
		didSet{
			let formatter = NSDateFormatter()
			formatter.dateFormat = "h:mm a, MM/dd/YYYY"
			let time = NSDate().timeIntervalSince1970
			epochTime = time
			timeLabel.text = formatter.stringFromDate(NSDate(timeIntervalSince1970: time))
		}
	}
	
	
	@IBOutlet weak var descriptionText: UITextView!{
		didSet{
			descriptionText.layer.borderWidth = 2.0
			descriptionText.layer.borderColor = UIColor.blackColor().CGColor
			descriptionText.layer.cornerRadius = 7
			descriptionText.clipsToBounds = true
		}
	}
	
	@IBOutlet weak var takePicOverlay: UIButton!
	
	var name : String?
	var leftImage : UIImage?
	var rightImage : UIImage?
	var witnessID: String?
	var doerID: String?
	var coordinates: CLLocationCoordinate2D?
	var epochTime : NSTimeInterval?
	var imagePicker: UIImagePickerController!
	
	//WHEN THE VIEW LOADS A PICTURE PICKER WILL LOAD RIGHT AWAY
    override func viewDidLoad() {
        super.viewDidLoad()
		takePic()
	}
	
	override func viewWillAppear(animated: Bool) {
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

	//CONTROLS THE LITTLE RED "X" BUTTON
	//WHEN A PICTURE IS REMOVED, THE PICTURE PICKER WILL AUTOMATICALLY POP UP
	@IBAction func removePic(sender: UIButton) {
		view.endEditing(true)
		takePic()
	}
	
	//SENDS THE POST TO THE DATABASE
	@IBAction func postButton(sender: UIButton) {
		view.endEditing(true)
		sendPost()
	}
	
	//CURRENTLY DISABLED
	@IBAction func takePicOverlayButton(sender: AnyObject) {
		view.endEditing(true)
		takePic()
	}
	
	//BRINGS UP THE PICTURE PICKER FOR TAKING A PICTURE
	func takePic(){
		if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
			if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
				imagePicker =  UIImagePickerController()
				imagePicker.delegate = self
				imagePicker.allowsEditing = false
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
	
	//DICTATES WHAT HAPPENS WHEN A PICTURE IS SELECTED
	//WHEN SELECTED, THE PICTURE WILL BE PUT IN THE PICTURE CONTAINER OF THE VIEW
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		print("Got an image")
		if let pickedImage:UIImage = (info[UIImagePickerControllerOriginalImage]) as? UIImage {
			leftImageView.image = pickedImage
			removePicture.hidden = false
		}
		imagePicker.dismissViewControllerAnimated(true, completion: {})
	}

	//WHAT HAPPENS WHEN USER CANCELS HAVING A PICTURE
	//USER WILL DESEGUE BACK TO MAP VIEW
	func imagePickerControllerDidCancel(picker: UIImagePickerController) {
		print("User canceled image")
		dismissViewControllerAnimated(true, completion: {
			self.navigationController?.popViewControllerAnimated(true)
			// Anything you want to happen when the user selects cancel
		})
	}

	
	//HTTP POST REQUEST TO SUBMIT POST THE DATABASE
	//CREATES A MULTIPART BODY WITH PARAMETERS AND TWO VERSIONS OF THE TAKEN PICTURE
	//HIGHQUALITY PICTURE WILL BE DISPLAYED IN DETAILED DISPLAYS
	//LOWQUALITY PICTURE WILL BE DISPLAYED AS A THUMBNAIL
	//SERVER WILL RETURN A JSON OBJECT OF DATABASES RESPONSE
	func sendPost(){
		if(descriptionText.text == "" || leftImageView.image == nil){
			AlertHelper.helper.alertMe(alertTitle:"Oh No!", messageToShow: "Please have a picture and write a description", actionTitle: "Will Do!", fromController: self)
			return
		}
		startThinking()
		
		let request = HTTPHelper.helper.buildRequest(ToWhere: "/api/newPost", HTTPMethod: "Post", authType: .Token, contentType: .Multipart)
		let params = [
			"witnessID":User.USER.userID!,
			"doerID":doerID!,
			"time":epochTime!.description,
			"latitude":"\(coordinates!.latitude)",
			"longitude":"\(coordinates!.longitude)",
			"description":descriptionText.text!
		]
		let image = leftImageView.image
		let requestBody = NSMutableData();
		HTTPHelper.helper.addParamsToBody(params, body: requestBody)
		HTTPHelper.helper.addJPGToBody("eventPictureUpload", imageName: "highQuality", image: image!, compressionQuality: 0.65, body: requestBody)
		HTTPHelper.helper.addJPGToBody("eventPictureUpload", imageName: "lowQuality", image: image!, compressionQuality: 0.05, body: requestBody)
		HTTPHelper.helper.closeMultipartBody(requestBody)
		request.HTTPBody = requestBody
		
		HTTPHelper.helper.sendRequest(request){
			error, data in
			if(error != nil){
				print("DATA RECIEVE ERROR=\(error)")
				self.stopThinking()
				AlertHelper.helper.alertMe(alertTitle: "Uh Oh", messageToShow: "Something Happened", actionTitle: "I'll Try Again", fromController: self)
								return
			}
			do{
				let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
				guard let insertedRecord = json["inserted"] else {
					self.stopThinking()
					AlertHelper.helper.alertMe(alertTitle: "Uh Oh", messageToShow: "Something Happened", actionTitle: "I'll Try Again", fromController: self)
					return
				}
				if(insertedRecord as! Int != 0){
					self.stopThinking()
					AlertHelper.helper.alertMeWithOKComplete(alertTitle: "It Posted!", messageToShow: "Your Post Was Made!", actionTitle: "Yay!", fromController: self){ action in
							self.navigationController?.popToRootViewControllerAnimated(true)
					}
				}
				else{
					self.stopThinking()
					AlertHelper.helper.alertMe(alertTitle: "Uh Oh", messageToShow: "Something Happened", actionTitle: "I'll Try Again", fromController: self)
					return
				}
			} catch {
				print("JSON PARSE ERROR=\(error)")
				self.stopThinking()
				AlertHelper.helper.alertMe(alertTitle: "Uh Oh", messageToShow: "Something Happened", actionTitle: "I'll Try Again", fromController: self)
				return
			}
		}
	}
	
	
	
}

//CODE BELOW IS FOR DIFFERENT IMPLEMENTATION OF HOW PICTURES WILL BE TAKEN

//import AVFoundation

// AVCaptureVideoDataOutputSampleBufferDelegate protocol and related methods
//extension PostVC:  AVCaptureVideoDataOutputSampleBufferDelegate{
//		//Camera Capture requiered properties
//		var videoDataOutput: AVCaptureVideoDataOutput!;
//		var videoDataOutputQueue : dispatch_queue_t!;
//		var previewLayer:AVCaptureVideoPreviewLayer!;
//		var captureDevice : AVCaptureDevice!
//		let session=AVCaptureSession();
//		var currentFrame:CIImage!
//		var done = false;
//
//		func clearPicture2(){
//		startCamera()
//		leftImageView.hidden = true
//		removePicture.hidden = true
//
//		previewView.hidden = false
//		takePicOverlay.hidden = false
//
//		@IBOutlet weak var previewView: UIView!{
//			didSet{
//				
//			}
//		}
//
//
//	}
//
//
//		override func shouldAutorotate() -> Bool {
//			if (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft ||
//				UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight ||
//				UIDevice.currentDevice().orientation == UIDeviceOrientation.Unknown) {
//				return false;
//			}
//			else {
//				return true;
//			}
//		}
//
//	func takePic2(){
//		if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
//			if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
//				imagePicker =  UIImagePickerController()
//				imagePicker.delegate = self
//				imagePicker.allowsEditing = false
//				imagePicker.sourceType = .Camera
//				imagePicker.cameraCaptureMode = .Photo
//				presentViewController(imagePicker, animated: true, completion: nil)
//			} else {
//				print("no rear camera")
//			}
//		} else {
//			print("cant use cam")
//		}
//	}
//
//
//	func imagePickerController2(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//		print("Got an image")
//		if let pickedImage:UIImage = (info[UIImagePickerControllerOriginalImage]) as? UIImage {
//			leftImageView.image = pickedImage
//			stopCamera()
//			previewView.hidden = true
//			takePicOverlay.hidden = true
//			leftImageView.hidden = false
//			removePicture.hidden = false
//		}
//		imagePicker.dismissViewControllerAnimated(true, completion: {})
//	}
//
//
//	func setupAVCapture(){
//		session.sessionPreset = AVCaptureSessionPreset640x480;
//		
//		let devices = AVCaptureDevice.devices();
//		// Loop through all the capture devices on this phone
//		for device in devices {
//			// Make sure this particular device supports video
//			if (device.hasMediaType(AVMediaTypeVideo)) {
//				// Finally check the position and confirm we've got the front camera
//				if(device.position == AVCaptureDevicePosition.Back) {
//					captureDevice = device as? AVCaptureDevice;
//					if captureDevice != nil {
//						beginSession();
//						done = true;
//						break;
//					}
//				}
//			}
//		}
//	}
//	
//	func beginSession(){
//		var err : NSError? = nil
//		var deviceInput:AVCaptureDeviceInput?
//		do {
//			deviceInput = try AVCaptureDeviceInput(device: captureDevice)
//		} catch let error as NSError {
//			err = error
//			deviceInput = nil
//		};
//		if err != nil {
//			print("error: \(err?.localizedDescription)");
//		}
//		if self.session.canAddInput(deviceInput){
//			self.session.addInput(deviceInput);
//		}
//		
//		self.videoDataOutput = AVCaptureVideoDataOutput();
//		self.videoDataOutput.alwaysDiscardsLateVideoFrames=true;
//		self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
//		self.videoDataOutput.setSampleBufferDelegate(self, queue:self.videoDataOutputQueue);
//		if session.canAddOutput(self.videoDataOutput){
//			session.addOutput(self.videoDataOutput);
//		}
//		self.videoDataOutput.connectionWithMediaType(AVMediaTypeVideo).enabled = true;
//		
//		self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session);
//		self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//		
//		let rootLayer :CALayer = self.previewView.layer;
//		rootLayer.masksToBounds=true;
//		self.previewLayer.frame = rootLayer.bounds;
//		rootLayer.addSublayer(self.previewLayer);
//		session.startRunning();
//		
//	}
//	
//	func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
//		currentFrame =   self.convertImageFromCMSampleBufferRef(sampleBuffer);
//	}
//	
//	// clean up AVCapture
//	func stopCamera(){
//		session.stopRunning()
//		done = false;
//	}
//	func startCamera(){
//		session.startRunning()
//		done = true
//	}
//	func convertImageFromCMSampleBufferRef(sampleBuffer:CMSampleBuffer) -> CIImage{
//		let pixelBuffer:CVPixelBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!;
//		let ciImage:CIImage = CIImage(CVPixelBuffer: pixelBuffer)
//		return ciImage;
//	}
//}
