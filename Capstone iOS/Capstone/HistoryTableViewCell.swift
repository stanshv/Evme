//
//  HistoryTableViewCell.swift
//  Capstone
//
//  Created by Stanley Shvartsberg on 4/26/16.
//  Copyright © 2016 StanleyShvartsberg. All rights reserved.
//

import UIKit

//PROTOTYPE CELL PROPERTIES FOR THE HISTORYTABLE
class HistoryTableViewCell: UITableViewCell {

	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var eventImageView: UIImageView!
	@IBOutlet weak var profileImageView: UIImageView!{
		didSet{
			profileImageView.layer.borderWidth = 2.0
			profileImageView.layer.masksToBounds = false
			profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
			profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2
			profileImageView.clipsToBounds = true
		}
	}
	@IBOutlet weak var firstNameLabel: UILabel!
	@IBOutlet weak var lastNameLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var karmaLabel: UILabel!
	@IBOutlet weak var coverView: UIView!
	

}
