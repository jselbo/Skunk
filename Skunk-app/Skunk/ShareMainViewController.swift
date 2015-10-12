//
//  ShareMainViewController.swift
//  Skunk
//
//  Created by Josh on 9/15/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import MapKit
import UIKit

class ShareMainViewController: UIViewController, LocationUser {
    
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
        if !authorized {
            locationManager.requestAuthorizationIfNotAuthorized { (authorized) -> Void in
                if authorized {
                    self.initializeAfterAuthorization()
                } else {
                    self.presentErrorAlert(Constants.needAuthorizationMessage)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if var destinationController = segue.destinationViewController as? LocationUser {
            destinationController.locationManager = locationManager
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
