//
//  ReceiverPickUpSharerViewController.swift
//  Skunk
//
//  Created by Anant Goel on 10/21/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit

class ReceiverPickUpSharerViewController: UIViewController {
    
    var accountManager: UserAccountManager!
    var sessionManager: ShareSessionManager!
    var sharerSession: ShareSession!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Pickup Request for \(sharerSession.sharerAccount.userAccount.fullName)"
        
        datePicker.minimumDate = NSDate()
        
        switch sharerSession.endCondition {
        case .Time(let date):
            datePicker.maximumDate = date
        default:
            break
        }
    }
    
    @IBAction func submitButton(sender: AnyObject) {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinner.startAnimating()
        spinner.center = submitButton.center - submitButton.frame.origin
        submitButton.addSubview(spinner)
        
        sharerSession.driverEstimatedArrival = datePicker.date
        sessionManager.sessionPickUpResponse(sharerSession) { (success) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                spinner.removeFromSuperview()
                
                if success {
                    let userIdentifier = self.accountManager.registeredAccount!.identifier
                    let receiverInfo = self.sharerSession.findReceiver(userIdentifier)!
                    receiverInfo.stopSharingState = .Accepted
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.presentErrorAlert("Failed to submit request to stop receiving updates")
                    self.submitButton.enabled = true
                    self.submitButton.backgroundColor = UIColor.redColor()
                }
            })
        }
    }
}