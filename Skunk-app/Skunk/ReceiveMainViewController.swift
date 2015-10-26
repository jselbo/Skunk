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
    var locationManager: LocationManager!

    var refreshTimer: NSTimer!
    
    @IBOutlet weak var optionsViewPanel: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var canPickUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.receiverSessionRefreshInterval, target: self, selector: "sessionRefresh:", userInfo: nil, repeats: true)
        
        self.getLocation(sharerSession.currentLocation!)

    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        refreshTimer.invalidate()
        refreshTimer = nil
    }
    
    @IBAction func canPickUp(sender: AnyObject) {
        sessionManager.sessionDriverResponse(sharerSession) { (success) -> () in
            if(success) {

            } else {
                self.presentErrorAlert("Can't Submit Repsonse Currently")
            }
        }
    }

    @IBAction func stopRecievingUpdates(sender: AnyObject) {
        sessionManager.sessionTermResponse(sharerSession) { (success) -> () in
            if(success) {
                
            } else {
                self.presentErrorAlert("Can't Submit Response Currently")
            }
        }
    }
    
    func sessionRefresh(sender: AnyObject) {
        sessionManager.fetchShareSession(accountManager.registeredAccount!,
            identifier: sharerSession.identifier!) { (session) -> () in
            self.sharerSession = session
                
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let session = session {
                    print("location: \(session.currentLocation)")
                    self.getLocation(session.currentLocation!)
                    
                } else {
                    self.presentErrorAlert("Failed to fetch updated session")
                }
            })
        }
    }
    
    func getLocation(location: CLLocation) {
        mapView.removeAnnotations(mapView.annotations)
        
        let latDelta:CLLocationDegrees = 0.01
        let longDelta:CLLocationDegrees = 0.01
        
        let initialLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let pointLocation:CLLocationCoordinate2D = initialLocation
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(pointLocation, theSpan)
        mapView.setRegion(region, animated: true)
        
        let pinLocation : CLLocationCoordinate2D = initialLocation
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = "Friend in Need"
        self.mapView.addAnnotation(objectAnnotation)
        
    }
    
}
