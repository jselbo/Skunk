//
//  ShareMainViewController.swift
//  Skunk
//
//  Created by Josh on 9/15/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import MapKit
import UIKit

class ShareMainViewController: UIViewController {
    
    let optionsSegue = "Options"
    
    var accountManager: UserAccountManager!
    var locationManager: LocationManager!
    var authorized = false
    
    @IBOutlet weak var personalMapView: MKMapView!
    @IBOutlet weak var shareButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.enabled = false
        shareButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !authorized {
            locationManager.requestAuthorizationIfNotAuthorized { (authorized) -> Void in
                if authorized {
                    self.initializeAfterAuthorization()
                } else {
                    self.presentErrorAlert(Constants.needLocationAuthorizationMessage)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case optionsSegue?:
            let optionsController = segue.destinationViewController as! SharerOptionsViewController
            optionsController.accountManager = accountManager
            optionsController.locationManager = locationManager
        default:
            break
        }
    }
    
    @IBAction func sharePressed(sender: AnyObject) {
        
    }
    
    private func initializeAfterAuthorization() {
        shareButton.enabled = true
        shareButton.setTitleColor(Constants.systemBlueColor, forState: .Normal)
        
        personalMapView.userTrackingMode = .Follow
        
        authorized = true
    }

}
