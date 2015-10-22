//
//  ReceiveMainViewController.swift
//  Skunk
//
//  Created by Josh on 9/15/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit
import MapKit

class ReceiveMainViewController: UIViewController {
    
    var accountManager: UserAccountManager!
    var sessionManager: ShareSessionManager!
    var sharerSession: ShareSession!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var optionsViewPanel: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentLocation = sharerSession.currentLocation
        let center = CLLocationCoordinate2D(latitude: (currentLocation?.coordinate.latitude)!, longitude: (currentLocation?.coordinate.longitude)!)
        let region = MKCoordinateRegionMake(center, MKCoordinateSpanMake(0.01, 0.01))
        mapView.setRegion(region, animated: true)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func canPickUpButton(sender: AnyObject) {
        sessionManager.sessionDriverResponse(sharerSession) { (success) -> () in
            if(success) {
                
            } else {
                self.presentErrorAlert("Can't Submit Repsonse Currently")
            }
        }
    }

    @IBAction func StopReceivingUpdatesButton(sender: AnyObject) {
        sessionManager.sessionTermResponse(sharerSession) { (success) -> () in
            if(success) {
                
            } else {
                self.presentErrorAlert("Can't Submit Response Currently")
            }
        }
    }
}
