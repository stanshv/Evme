//
//  FirstViewController.swift
//  Capstone
//
//  Created by Stanley Shvartsberg on 2/10/16.
//  Copyright © 2016 StanleyShvartsberg. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

	
	@IBOutlet weak var coverView: UIView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var mapView: MKMapView!{
		didSet{
			mapView.delegate = self
		}
	}
	
	var locationManager = CLLocationManager()
	var lastLocation = CLLocation()
	
	//WHEN VIEW LOADS LOCATION SETTINGS ARE SET
	override func viewDidLoad() {
		super.viewDidLoad()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.distanceFilter = 1.0
		locationManager.requestAlwaysAuthorization()
		mapView.showsUserLocation = true
	}
	
	//ANYTIME VIEW APPEARS THE LOCATION OF USER IS UPDATED
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		locationManager.requestLocation()
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
	
	//DICTATES WHAT HAPPENS WHEN A USER LOCATION IS UPDATED
	//WILL CHECK THAT LOCATION CHANGE IS OF SIGNIFICANT IMPORTANCE
	//WILL UPDATE USERS LOCATION ON SERVER IF LOCATION CHECK PASSES
	//WILL UPDATE OTHER USERS AROUND LOCAL USER
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let location = locations.last
		
		//Checks to see if the location update is new
		let locationAge: NSTimeInterval = -(location?.timestamp.timeIntervalSinceNow)!
		if(locationAge>5.0){ return }
		
		//Checks to see if the location update is significant
		let distance = (location?.distanceFromLocation(lastLocation))!
		if(distance > 0.5){
			lastLocation = location!
			let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
			let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
			mapView.setRegion(region, animated: true)
			updateMyLocation((location?.coordinate)!)
		}
		findAroundMe()
	}
	
	//WHAT HAPPENS IF LOCATION FAILS UPDATING
	func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
		AlertHelper.helper.alertMe(alertTitle: "Oh No", messageToShow: "Looks Like You Don't Have A Signal", actionTitle: "I'll Try When I Do", fromController: self)
		print("ERROR: " + error.localizedDescription)
	}
	
	
	//HOW TO DISPLAY AN ANNOTATION
	//IF THE ANNOTATION IS THE USERS LOCATION IT WILL BE DISPLAYED AS A BLUE CIRCLE
	//IF THE ANNOTATION IS OTHERS USERS IT WILL RECEIVE CUSTOM PROPERTIES
	//WILL HAVE A THUMBNAIL DISPLAY OF PICTURE
	//WILL HAVE A CALL OUT ACCESSORY TO MOVE TO THE POST PAGE
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		if (annotation is MKUserLocation) {
			//if annotation is not an MKPointAnnotation (eg. MKUserLocation),
			//return nil so map draws default view for it (eg. blue dot)...
			return nil
		}
		var view = mapView.dequeueReusableAnnotationViewWithIdentifier("USERS") as? MKPinAnnotationView
		
		if view == nil{
			view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "USERS")
			view!.canShowCallout = true
			view!.pinTintColor = UIColor(red: (50.0/255.0), green: (112.0/255.0), blue: (86.0/255.0), alpha: 1.0)
			view!.animatesDrop = true
		}
		else{
			view!.annotation = annotation
		}
		view!.leftCalloutAccessoryView = nil
		view!.rightCalloutAccessoryView = nil
		view!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
		view!.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
		return view
	}
	
	//WHEN A PIN IS SELECTED IT WILL DISPLAY ITS CUSTOM FEATURES AND INFORMATION
	func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
		if((view.annotation?.isKindOfClass(MapPin)) == true){
			let selectedPin = view.annotation as! MapPin
			if let thumbnailImageView = view.leftCalloutAccessoryView as? UIImageView{
				thumbnailImageView.image = selectedPin.profilePic
			}
		}
	}
	
	//WHEN CALL OUT ACCESSORY IS TAPPED WILL TRIGGER SEGUE TO THE POST PAGE
	func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		performSegueWithIdentifier("CALLOUTACCESSORY", sender: view)
	}
	
	//CHECKS THAT THE SELECTED PIN IS OF PROPER TYPE
	//SETS UP DATA IN THE NEXT VIEW CONTROLLER(POST PAGE)
	//SEGUES TO THE POST PAGE
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if(segue.identifier == "CALLOUTACCESSORY") {
			
			let nextVC = (segue.destinationViewController as! PostVC)
			let mkAnnView = sender as! MKAnnotationView
			let pin = mkAnnView.annotation as! MapPin
			nextVC.doerID = pin.valueForKey("userID") as? String
			nextVC.coordinates = pin.coordinate
			nextVC.name = pin.title
			let thumbnailImageView = (mkAnnView.leftCalloutAccessoryView as! UIImageView).image
			nextVC.leftImage = thumbnailImageView
			
		}
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
	}

	//TRIGGERS A LOCATION UPDATE
	@IBAction func updateButton(sender: UIButton) {
		locationManager.requestLocation()
	}
	
	//HTTP PUT REQUEST THAT WILL UPDATE THE LOCATION OF THE USER ON THE DATABASE
	//RESPONSE WILL BE A STRING DICTATING IF IT WORKED
	//NECESSARY TO UPDATE USERS LOCATION SO THAT PEOPLE CAN FIND EACH OTHER
	func updateMyLocation(locationCoord: CLLocationCoordinate2D){
		let lat = locationCoord.latitude
		let long = locationCoord.longitude
		let request = HTTPHelper.helper.buildRequest(ToWhere: "/api/updateMyLocation", HTTPMethod: "PUT", authType: .Token, contentType: .XWWW)
		request.HTTPBody = "lat=\(lat)&long=\(long)".dataUsingEncoding(NSUTF8StringEncoding)
		HTTPHelper.helper.sendRequest(request){
			error, data in
			if(error != nil){
				print("DATA RECIEVE ERROR=\(error)")
				return
			}
			let response = NSString(data: data!, encoding: NSUTF8StringEncoding)!
			print("Server: \(response)")
		}
	}
	
	//HTTP GET REQUEST THAT WILL REQUEST ALL OTHER USERS AROUND THE LOCAL USER
	//DISTANCE TO USER IS SET ON THE SERVER
	//SERVER WILL RESPOND WITH AN ARRAY OF DICTIONARIES CONTAINING LIMITED USER DATA
	//EACH DICTIONARY WILL CONTAIN A LOW QUALITY PROFILE PICTURE
	func findAroundMe(){
		startThinking()
		mapView.removeAnnotations(self.mapView.annotations)
		let request = HTTPHelper.helper.buildRequest(ToWhere: "/api/findUsersNearMe", HTTPMethod: "GET", authType: .Token, contentType: .XWWW)
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
				
				for person in json{
					let id = person["id"]! as! String
					let storedID = User.USER.userID!
					if(id == storedID){
						continue
					}
					let fname = person["fname"]!
					let karma = person["karma"]!
					let lat = person["latitude"]!
					let long = person["longitude"]!
					let profilePicString = person["lowQProfile"]! as! String
					
					let pin = MapPin()
					pin.coordinate.latitude = lat as! CLLocationDegrees
					pin.coordinate.longitude = long as! CLLocationDegrees
					pin.title = "\(fname)"
					pin.subtitle = "Karma: \(karma)"
					pin.userID = "\(id)"
					
					if(profilePicString == "defaultuserpic"){
						pin.profilePic = UIImage(named: "defaultuser")!
					}
					else{
						let imageData = NSData(base64EncodedString: profilePicString, options: NSDataBase64DecodingOptions(rawValue: 0))
						pin.profilePic = UIImage(data: imageData!)
					}
					self.mapView.addAnnotation(pin)
				}
				self.stopThinking()
			} catch {
				self.stopThinking()
				AlertHelper.helper.alertMe(alertTitle: "Uh Oh", messageToShow: "Something Happened", actionTitle: "I'll Try Again", fromController: self)
				print("JSON PARSE ERROR=\(error)")
				return
			}
		}
	}
	
	
}


