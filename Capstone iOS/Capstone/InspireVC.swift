//
//  InspireVC.swift
//  Evme
//
//  Created by Stanley Shvartsberg on 5/9/16.
//  Copyright © 2016 StanleyShvartsberg. All rights reserved.
//

import UIKit
import MapKit

class InspireVC: UIViewController {

	
	@IBOutlet var masterView: UIView!
	@IBOutlet weak var coverView: UIView!
	
	@IBOutlet weak var eventPictureView: UIImageView!
	@IBOutlet weak var profilePictureView2: UIImageView!{
		didSet{
			profilePictureView2.layer.borderWidth = 2.0
			profilePictureView2.layer.masksToBounds = false
			profilePictureView2.layer.borderColor = UIColor.whiteColor().CGColor
			profilePictureView2.layer.cornerRadius = profilePictureView.frame.size.height/2
			profilePictureView2.clipsToBounds = true
		}
	}

	@IBOutlet weak var profilePictureView: UIImageView!{
		didSet{
			profilePictureView.layer.borderWidth = 2.0
			profilePictureView.layer.masksToBounds = false
			profilePictureView.layer.borderColor = UIColor.whiteColor().CGColor
			profilePictureView.layer.cornerRadius = profilePictureView.frame.size.height/2
			profilePictureView.clipsToBounds = true
		}
	}
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var smallLabel: UILabel!
	@IBOutlet weak var smallLabel2: UILabel!
	@IBOutlet weak var smallLabel3: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	var detailData : NSDictionary = [:]
	var ignoreShake = false
	//WHEN THE VIEW LOADS, A NEW GOOD DEED WILL BE DOWNLOADED
    override func viewDidLoad() {
        super.viewDidLoad()
		getRandomDetailData()
        // Do any additional setup after loading the view.
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func canBecomeFirstResponder() -> Bool {
		return true
	}
	
	//A SHAKE GESTURE WILL TRIGGER A NEW POST TO DOWNLOAD
	override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
		if(motion == .MotionShake && ignoreShake == false){
			self.getRandomDetailData()
		}
	}
	
	//CONTROLS PROPERTIES IN THE VIEW CONTROLLER THAT SHOW APP IS "THINKING"
	//DISABLES USER INTERACTION TO PREVENT HUMAN ERROR
	func startThinking(){
		coverView.hidden = false
		activityIndicator.startAnimating()
		UIApplication.sharedApplication().beginIgnoringInteractionEvents()
		ignoreShake = true
	}
	
	//ENDS "THINKING"
	//ENABLES USER INTERACTION AGAIN
	func stopThinking(){
		coverView.hidden = true
		activityIndicator.stopAnimating()
		UIApplication.sharedApplication().endIgnoringInteractionEvents()
		ignoreShake = false
	}
	
	//HTTP GET REQUEST THAT WILL QUERY THE SERVER FOR A RANDOM GOOD DEED
	//WILL RETURN A DICTIONARY CONTAINING ALL INFORMATION
	//THREE PICTURES ARE DOWNLOADED
	//PICTURE OF THE EVENT IN HIGH QUALITY
	//PROFILE PICTURE OF WITNESS IN LOW QUALITY
	//PROFILE PICTURE OF DOER IN LOW QUALITY
	//ALL OTHER PARAMETERS REQUIRED FOR THE PAGE
	func getRandomDetailData(){
		startThinking()
		mapView.removeAnnotations(mapView.annotations)
		let request = HTTPHelper.helper.buildRequest(ToWhere: "/api/getRandomDetailedPost", HTTPMethod: "GET", authType: .Token, contentType: .XWWW)
		HTTPHelper.helper.sendRequest(request){
			error, data in
			if(error != nil){
				print("DATA RECIEVE ERROR=\(error)")
				self.stopThinking()
				AlertHelper.helper.alertMe(alertTitle: "Whoops!", messageToShow: "Something Went Wrong", actionTitle: "Got It", fromController: self)
				return
			}
			do{
				let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSMutableDictionary
				let eventPicString = json["eventPic"]! as! String
				let eventPicData = NSData(base64EncodedString: eventPicString, options: NSDataBase64DecodingOptions(rawValue: 0))
				self.eventPictureView.image = UIImage(data: eventPicData!)
				let doerPicString = json["doerPic"]! as! String
				let doerPicData = NSData(base64EncodedString: doerPicString, options: NSDataBase64DecodingOptions(rawValue: 0))
				self.profilePictureView2.image = UIImage(data: doerPicData!)
				let witnessPicString = json["witnessPic"]! as! String
				let witnessPicData = NSData(base64EncodedString: witnessPicString, options: NSDataBase64DecodingOptions(rawValue: 0))
				self.profilePictureView.image = UIImage(data: witnessPicData!)
				let time = json["eventTime"]! as! Double
				let dateFormatter = NSDateFormatter()
				let timeFormatter = NSDateFormatter()
				dateFormatter.dateFormat = "MM/dd/YYYY"
				timeFormatter.dateFormat = "h:mm a"
				let timeString = timeFormatter.stringFromDate(NSDate(timeIntervalSince1970: time))
				let dateString = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: time))
				self.smallLabel.text = "On \(dateString) at \(timeString)"
				self.smallLabel2.text = "\(json["witnessFName"]!) \(json["witnessLName"]!) saw"
				self.smallLabel3.text = "\(json["doerFName"]!) \(json["doerLName"]!) do this:"
				let eventLocation = CLLocationCoordinate2D(latitude: json["eventLocationLat"] as! Double, longitude: json["eventLocationLong"] as! Double)
				let region = MKCoordinateRegion(center: eventLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
				self.mapView.setRegion(region, animated: true)
				let pin = MapPin(coordinate: eventLocation)
				self.mapView.addAnnotation(pin)
				self.stopThinking()
				self.descriptionLabel.text = "\(json["eventDescription"]!)"
				} catch {
					self.stopThinking()
					print("JSON PARSE ERROR=\(error)")
				return
			}
		}
	}

	
}
