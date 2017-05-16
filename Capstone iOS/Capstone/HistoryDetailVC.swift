//
//  HistoryDetailVC.swift
//  Capstone
//
//  Created by Stanley Shvartsberg on 4/27/16.
//  Copyright © 2016 StanleyShvartsberg. All rights reserved.
//

import UIKit
import MapKit

//VIEW CONTROLLER FOR THE GOOD DEED DETAIL PAGE
class HistoryDetailVC: UIViewController {

	//PICTURE OF THE DEED
	@IBOutlet weak var goodDeedPictureView: UIImageView!{
		didSet{
			let imageBase64String = detailData["highQPic"]! as! String
			let imageData = NSData(base64EncodedString: imageBase64String, options: NSDataBase64DecodingOptions(rawValue: 0))
			goodDeedPictureView.image = UIImage(data: imageData!)
		}
	}
	
	//UPPER PROFILE PICTURE OF OTHER PARTY INVOLVED
	@IBOutlet weak var upperProfilePictureView: UIImageView!{
		didSet{
			let profilePicString = detailData["lowQProfile"]! as! String
			if(profilePicString == "defaultuserpic"){
				upperProfilePictureView.image = UIImage(named: "defaultuser")!
			}
			else{
				let profilePicData = NSData(base64EncodedString: profilePicString, options: NSDataBase64DecodingOptions(rawValue: 0))
				upperProfilePictureView.image = UIImage(data: profilePicData!)
			}
			upperProfilePictureView.layer.borderWidth = 2.0
			upperProfilePictureView.layer.masksToBounds = false
			upperProfilePictureView.layer.borderColor = UIColor.whiteColor().CGColor
			upperProfilePictureView.layer.cornerRadius = upperProfilePictureView.frame.size.height/2
			upperProfilePictureView.clipsToBounds = true
			
		}
	}
	//PROFILE PICTURE OF THE USER, NOT USED
	@IBOutlet weak var lowerProfilePictureView: UIImageView!
	
	//MAP VIEW THAT SHOWS LOCATION OF THE EVENT
	@IBOutlet weak var mapView: MKMapView!{
		didSet{
			let latitude = detailData["latitude"]! as! CLLocationDegrees
			let longitude = detailData["longitude"]! as! CLLocationDegrees
			let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
			let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
			self.mapView.setRegion(region, animated: true)
			let pin = MapPin(coordinate: center)
			self.mapView.addAnnotation(pin)
		}
	}
	
	//DISPLAYS TIME STAMP OF EVENT
	@IBOutlet weak var smallLabel: UILabel!{
		didSet{
			let dateFormatter = NSDateFormatter()
			let timeFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "MM/dd/YYYY"
			timeFormatter.dateFormat = "h:mm a"
			let epochTime = detailData["time"]! as! Double
			let timeString = timeFormatter.stringFromDate(NSDate(timeIntervalSince1970: epochTime))
			let dateString = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: epochTime))
			self.smallLabel.text = "On \(dateString) at \(timeString)"
		}
	}
	
	//DISPLAYS NAME OF OTHER PARTY INVOLVED AND WHETHER YOU ARE WITNESS OR DOER
	@IBOutlet weak var smallLabel2: UILabel!{
		didSet{
			var labelText = "\(detailData["fname"]!) saw you do this:"
			if(detailData["witnessID"] as? String == User.USER.userID){
				labelText = "You saw \(detailData["fname"]!) do this:"
			}
			smallLabel2.text = "\(labelText)"
		}
	}
	
	//DESCRIPTION OF THE EVENT
	@IBOutlet weak var eventDescriptionLabel: UILabel!{
		didSet{
			eventDescriptionLabel.text = "\(detailData["description"]!)"
		}
	}
	
	
	//DICTIONARY OF DATA OF EVENT, PASSED IN FROM A SEGUE
	var detailData : NSDictionary = [:]
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
