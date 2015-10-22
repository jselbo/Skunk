//
//  ReceiverPickUpSharerViewController.swift
//  Skunk
//
//  Created by Anant Goel on 10/21/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit

class ReceiverPickUpSharerViewController: UIViewController {
    
    var sessionManager: ShareSessionManager!
    var sharerSession: ShareSession!
    
    @IBOutlet weak var datePicked: UIDatePicker!
    @IBAction func submitButton(sender: AnyObject) {
        sharerSession.driverEstimatedArrival = datePicked.date
        sessionManager.sessionPickUpResponse(sharerSession) { (success) -> () in
            if(success) {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.presentErrorAlert("Communication with Server Failed")
            }
        }
    }
}