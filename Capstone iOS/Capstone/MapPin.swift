//
//  MapPin.swift
//  Capstone
//
//  Created by Stanley Shvartsberg on 4/24/16.
//  Copyright © 2016 StanleyShvartsberg. All rights reserved.
//

import Foundation
import MapKit

//CUSTOM MKANNOTATION CLASS THAT HOLDS MORE INFORMATION THAN A STANDARD MAP PIN
class MapPin: NSObject, MKAnnotation {
	
	var coordinate: CLLocationCoordinate2D
	var title: String?
	var subtitle: String?
	var userID: String?
	var profilePic: UIImage?
	
	override init(){
		self.coordinate = CLLocationCoordinate2D()
		super.init()
	}
	
	init(coordinate:CLLocationCoordinate2D) {
		self.coordinate = coordinate
		super.init()
	}
	
}