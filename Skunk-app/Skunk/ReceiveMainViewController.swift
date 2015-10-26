//
//  ReceiveMainViewController.swift
//  Skunk
//
//  Created by Josh on 9/15/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit
import MapKit

class ReceiveMainViewController: UIViewController, MKMapViewDelegate {
    
    var accountManager: UserAccountManager!
    var sessionManager: ShareSessionManager!
    var sharerSession: ShareSession!
    var locationManager: LocationManager!

    var refreshTimer: NSTimer!
    
    var sharerAnnotation: MKAnnotation?
    
    @IBOutlet weak var optionsViewPanel: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var stopReceivingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if sharerSession.endCondition.isLocation {
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.receiverSessionRefreshInterval, target: self, selector: "sessionRefresh:", userInfo: nil, repeats: true)
        
        if let currentLocation = sharerSession.currentLocation {
            self.showSharerLocationInMap(currentLocation)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        refreshTimer.invalidate()
        refreshTimer = nil
    }

    @IBAction func stopRecievingUpdates(sender: AnyObject) {
        stopReceivingButton.enabled = false
        stopReceivingButton.backgroundColor = UIColor.grayColor()
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinner.startAnimating()
        spinner.center = stopReceivingButton.center - stopReceivingButton.frame.origin
        stopReceivingButton.addSubview(spinner)
        
        sessionManager.sessionTermResponse(sharerSession) { (success) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                spinner.removeFromSuperview()
                
                if success {
                    let userIdentifier = self.accountManager.registeredAccount!.identifier
                    let receiverInfo = self.sharerSession.findReceiver(userIdentifier)!
                    receiverInfo.stopSharingState = .Accepted
                    
                    self.navigationController!.popViewControllerAnimated(true)
                } else {
                    self.presentErrorAlert("Failed to submit request to stop receiving updates")
                    self.stopReceivingButton.enabled = true
                    self.stopReceivingButton.backgroundColor = UIColor.redColor()
                }
            })
        }
    }
    
    func sessionRefresh(sender: AnyObject) {
        sessionManager.fetchShareSession(accountManager.registeredAccount!,
            identifier: sharerSession.identifier!) { (session) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let session = session {
                    self.sharerSession = session
                    
                    if let currentLocation = session.currentLocation {
                        self.showSharerLocationInMap(currentLocation)
                    }
                } else {
                    self.presentErrorAlert("Failed to fetch updated session")
                }
            })
        }
    }
    
    func showSharerLocationInMap(location: CLLocation) {
        if let sharerAnnotation = sharerAnnotation {
            mapView.removeAnnotation(sharerAnnotation)
        }
        
        let latDelta = CLLocationDegrees(0.01)
        let longDelta = CLLocationDegrees(0.01)
        
        let initialLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let span = MKCoordinateSpanMake(latDelta, longDelta)
        let pointLocation = initialLocation
        
        let region = MKCoordinateRegionMake(pointLocation, span)
        mapView.setRegion(region, animated: true)
        
        let pinLocation = initialLocation
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = pinLocation
        annotation.title = "Friend in Need"
        self.mapView.addAnnotation(annotation)
        
        sharerAnnotation = annotation
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let _ = annotation as? MKUserLocation {
            // Default to blue dot
            return nil
        }
        
        return nil
    }
    
}
