//
//  SharerOptionsViewController.swift
//  Skunk
//
//  Created by Don Phan on 9/20/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit
import MapKit

import ActionSheetPicker_3_0

class SharerOptionsViewController: UITableViewController, ShareSelectLocationViewControllerDelegate {
    
    private let selectLocationSegue = "SelectLocation"
    private let selectFriendsSegue = "SelectFriends"

    var accountManager: UserAccountManager!
    var locationManager: LocationManager!
    var sessionManager: ShareSessionManager!
    
    var endCondition: ShareEndCondition?
    
    @IBOutlet weak var requestRideOption: UISwitch!
    @IBOutlet weak var selectFriendsButton: UIButton!
    @IBOutlet weak var selectedValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // A sort-of hack that which delays content touches on the table view
        // and the wrapper view. Without this, the buttons are not immediately
        // responsive to touches.
        // See: http://stackoverflow.com/a/19671114
        for view in self.tableView.subviews {
            if let view = view as? UIScrollView {
                view.delaysContentTouches = false
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        switch identifier {
        case selectFriendsSegue:
            return validateOptions()
        default:
            return true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case selectLocationSegue?:
            let navigationController = segue.destinationViewController as! UINavigationController
            let destinationController = navigationController.topViewController as! ShareSelectLocationViewController
            destinationController.delegate = self
        case selectFriendsSegue?:
            let receiversController = segue.destinationViewController as! SharerSelectRecieverViewController
            receiversController.endCondition = endCondition
            receiversController.needsDriver = requestRideOption.on
            receiversController.accountManager = accountManager
            receiversController.locationManager = locationManager
            receiversController.sessionManager = sessionManager
        default:
            break
        }
    }
    
    //MARK: - IBAction
    
    @IBAction func selectTimePressed(sender: AnyObject) {
        let secondsInHour = NSTimeInterval(60 * 60)
        let secondsInDay = NSTimeInterval(secondsInHour * 24)
        
        let currentDate = NSDate()
        // Min. ending time is +1 hour from now
        let minimumDate = NSDate(timeInterval: secondsInHour, sinceDate: currentDate)
        // Max. ending time is +24 hours from now
        let maximumDate = NSDate(timeInterval: secondsInDay, sinceDate: currentDate)
        
        let datePicker = ActionSheetDatePicker(title: "Select a Time",
            datePickerMode: .DateAndTime,
            selectedDate: minimumDate,
            doneBlock: { picker, value, index in
                let selectedDate = value as! NSDate
                
                self.endCondition = .Time(selectedDate)
                self.selectedValueLabel.text = selectedDate.humanizedString()
            },
            cancelBlock: nil,
            origin: self.view)
        //DEFECT #2: Took out the checks for past dates
        //datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate
        datePicker.minuteInterval = 15
        
        datePicker.showActionSheetPicker()
    }
    
    //MARK: - ShareSelectLocationViewControllerDelegate
    
    func shareSelectLocationViewController(controller: ShareSelectLocationViewController, didSelectLocation coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        endCondition = .Location(location)
        
        selectedValueLabel.text = String(format: "Location [%.03f : %.03f]", coordinate.latitude, coordinate.longitude)
    }
    
    //MARK: - Private methods
    
    private func validateOptions() -> Bool {
        guard let endCondition = endCondition else {
            self.presentErrorAlert("Please choose an ending condition.")
            return false
        }
        
        switch endCondition {
            
        //DEFECT #2: Took out the checks for past dates

        case .Time(let _): break
            // Ensure selected date is still past the current time. This could occur if the user
            // stayed on this controller for an hour or more, and then tried to proceed.
            //let currentDate = NSDate()
            //guard currentDate.compare(date) == .OrderedAscending else {
            //    self.presentErrorAlert("Ending time must be in the future. Please select time again.")
            //    return false
            //}
        case .Location(_):
            // Nothing to validate
            break
        }
        
        return true
    }
    
}