//
//  HistoryTableVC.swift
//  Capstone
//
//  Created by Stanley Shvartsberg on 4/26/16.
//  Copyright © 2016 StanleyShvartsberg. All rights reserved.
//

import UIKit

//VIEW CONTROLLER FOR HISTORY TABLE PAGE, SHOWS A LISTING OF ALL DEEDS DONE OR SEEN
class HistoryTableVC: UITableViewController{
	
	//DATA THAT WAS DOWNLOADED FROM THE SERVER TO BE DISPLAYED
	var tableData : [NSDictionary] = []
	
	//DATA THAT WILL BE PASSED TO THE NEXT SEGUE
	var nextSegueData : NSMutableDictionary = [:]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//Sorts the array in descending order of events
		tableData.sortInPlace{
			item1, item2 in
			let time1 = item1["time"] as! Double
			let time2 = item2["time"] as! Double
			return time1 > time2
		}}
	
	//CREATES ONE SECTION IN THE TABLE
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	//DICTATES HOW MANY CELLS IN A SECTION
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableData.count
	}
	
	//CREATES AND POPULATES CONTENT FOR A PARTICULAR CELL
	//USES TABLEDATA FOR THE DATA AND USES HISTORYTABLECELL AS THE CELL TYPE
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("HistoryTableViewCell", forIndexPath: indexPath) as! HistoryTableViewCell
		
		cell.firstNameLabel.text = "\(tableData[indexPath.row]["fname"]!)"
		cell.lastNameLabel.text = "\(tableData[indexPath.row]["lname"]!)"
		cell.karmaLabel.text = "Has \(tableData[indexPath.row]["karma"]!) Karma"
		
		let dateFormatter = NSDateFormatter()
		let timeFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "MM/dd/YYYY"
		timeFormatter.dateFormat = "h:mm a"
		let epochTime = tableData[indexPath.row]["time"]! as! Double
		let timeString = timeFormatter.stringFromDate(NSDate(timeIntervalSince1970: epochTime))
		let dateString = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: epochTime))
		cell.timeLabel.text = "On \(dateString) at \(timeString)"
		
		let imageBase64String = tableData[indexPath.row]["lowQPic"]! as! String
		let imageData = NSData(base64EncodedString: imageBase64String, options: NSDataBase64DecodingOptions(rawValue: 0))
		cell.eventImageView.image = UIImage(data: imageData!)
		
		let profilePicString = tableData[indexPath.row]["lowQProfile"]! as! String
		if(profilePicString == "defaultuserpic"){
			cell.profileImageView.image = UIImage(named: "defaultuser")!
		}
		else{
			let profilePicData = NSData(base64EncodedString: profilePicString, options: NSDataBase64DecodingOptions(rawValue: 0))
			cell.profileImageView.image = UIImage(data: profilePicData!)
		}
		return cell
	}
	
	//DICTATES WHAT HAPPENS WHEN A CELL IS SELECTED
	//DATA IS DOWNLOADED FOR THE DETAIL HISTORY VIEW AND PASSED IN THE SEGUE
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let tableCell = tableView.cellForRowAtIndexPath(indexPath) as! HistoryTableViewCell
		nextSegueData.addEntriesFromDictionary(tableData[indexPath.row] as [NSObject : AnyObject])
		getDetailData( "\(tableData[indexPath.row]["postID"]!)", tableCell: tableCell)
	}
	
	//PASSES THE NEXTSEGUEDATA TO THE NEXT VIEW CONTROLLER
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		let nextVC = (segue.destinationViewController as! HistoryDetailVC)
		nextVC.detailData = nextSegueData
		//print("segue time")
	}
	
	//CONTROLS PROPERTIES IN THE VIEW CONTROLLER THAT SHOW APP IS "THINKING"
	//DISABLES USER INTERACTION TO PREVENT HUMAN ERROR
	func startThinking(coverView: UIView, activityIndicator: UIActivityIndicatorView){
		coverView.hidden = false
		activityIndicator.startAnimating()
		UIApplication.sharedApplication().beginIgnoringInteractionEvents()
	}
	
	//ENDS "THINKING"
	//ENABLES USER INTERACTION AGAIN
	func stopThinking(coverView: UIView, activityIndicator: UIActivityIndicatorView){
		coverView.hidden = true
		activityIndicator.stopAnimating()
		UIApplication.sharedApplication().endIgnoringInteractionEvents()
	}
	
	//HTTP GET REQUEST TO RECEIVE DETAIL DATA FOR NEXT VIEW CONTROLLER
	//WILL RECEIVE A DICTIONARY FOR A SINGLE GOOD DEED
	func getDetailData(postID : String, tableCell: HistoryTableViewCell){
		startThinking(tableCell.coverView, activityIndicator: tableCell.activityIndicator)
		let request = HTTPHelper.helper.buildRequest(ToWhere: "/api/getDetailedPost/\(postID)", HTTPMethod: "GET", authType: .Token, contentType: .XWWW)
		HTTPHelper.helper.sendRequest(request){
			error, data in
			if(error != nil){
				print("DATA RECIEVE ERROR=\(error)")
				self.stopThinking(tableCell.coverView, activityIndicator: tableCell.activityIndicator)
				AlertHelper.helper.alertMe(alertTitle: "Whoops!", messageToShow: "Something Went Wrong", actionTitle: "Got It", fromController: self)
				return
			}
			do{
				let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSMutableDictionary
				self.nextSegueData.addEntriesFromDictionary(json as [NSObject : AnyObject])
				self.stopThinking(tableCell.coverView, activityIndicator: tableCell.activityIndicator)
				self.performSegueWithIdentifier("SHOWHISTORYDETAIL", sender: "")
			} catch {
				self.stopThinking(tableCell.coverView, activityIndicator: tableCell.activityIndicator)
				AlertHelper.helper.alertMe(alertTitle: "Oh No", messageToShow: "Something Happened", actionTitle: "I'll Try Again", fromController: self)
				print("JSON PARSE ERROR=\(error)")
				return
			}
		}
	}

	
	
}
