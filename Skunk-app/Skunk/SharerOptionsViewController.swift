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
                self.dateSelected(currentDate, selectedDate)
            },
            cancelBlock: nil,
            origin: self.view)
        datePicker.minimumDate = minimumDate
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
    
    private func dateSelected(currentDate: NSDate, _ selectedDate: NSDate) {
        endCondition = .Time(selectedDate)
        
        // Dates and times are hard
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let currentComponents = calendar.components([.Day], fromDate: currentDate)
        let selectedComponents = calendar.components([.Day], fromDate: selectedDate)
        let dayText = (selectedComponents.day == currentComponents.day ? "Today" : "Tomorrow")
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "h:mm a"
        let timeText = formatter.stringFromDate(selectedDate)
        
        let differenceComponents = calendar.components([.Day, .Hour, .Minute], fromDate: currentDate, toDate: selectedDate, options: [])
        var hourDifference = Double(differenceComponents.hour)
        if differenceComponents.minute > 0 {
            hourDifference += Double(differenceComponents.minute) / 60.0
        }
        let hourText = String(format: "%.1f %@ from now",
            hourDifference, (hourDifference > 1.0 ? "hours" : "hour"))
        
        self.selectedValueLabel.text = "\(dayText) at \(timeText) (\(hourText))"
    }
    
    private func validateOptions() -> Bool {
        guard let endCondition = endCondition else {
            self.presentErrorAlert("Please choose an ending condition.")
            return false
        }
        
        switch endCondition {
        case .Time(let date):
            // Ensure selected date is still past the current time. This could occur if the user
            // stayed on this controller for an hour or more, and then tried to proceed.
            let currentDate = NSDate()
            guard currentDate.compare(date) == .OrderedAscending else {
                self.presentErrorAlert("Ending time must be in the future. Please select time again.")
                return false
            }
        case .Location(_):
            // Nothing to validate
            break
        }
        
        return true
    }
    
}