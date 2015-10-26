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
    
    let destinationPinIdentifier = "DestinationPin"
    let sharerPinIdentifier = "SharerPin"
    
    var accountManager: UserAccountManager!
    var sessionManager: ShareSessionManager!
    var sharerSession: ShareSession!
    var locationManager: LocationManager!

    var refreshTimer: NSTimer!
    
    var sharerAnnotation: MKAnnotation?
    var destinationAnnotation: MKAnnotation?
    
    @IBOutlet weak var optionsViewPanel: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var stopReceivingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = sharerSession.sharerAccount.userAccount.fullName
        
        switch sharerSession.endCondition {
        case .Location(let location):
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = "Destination"
            let sharerName = sharerSession.sharerAccount.userAccount.fullName
            annotation.subtitle = "Sharing will end when \(sharerName) reaches this location."
            
            mapView.addAnnotation(annotation)
            destinationAnnotation = annotation
            
            conditionLabel.text = "Sharing until destination"
        case .Time(let date):
            let text = "Sharing until \(date.humanizedString())"
            let atIndex = text.rangeOfString("at")!.endIndex
            conditionLabel.text =
                text.substringToIndex(atIndex) + "\n" + text.substringFromIndex(atIndex.advancedBy(1))
        }
        
        driverLabel.hidden = sharerSession.driverIdentifier != accountManager.registeredAccount!.identifier
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.receiverSessionRefreshInterval, target: self, selector: "sessionRefresh:", userInfo: nil, repeats: true)
        
        if let currentLocation = sharerSession.currentLocation {
            self.showSharerLocationInMap(currentLocation, updateTime: sharerSession.lastLocationUpdate!)
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
                        self.showSharerLocationInMap(currentLocation, updateTime: session.lastLocationUpdate!)
                    }
                    
                    self.driverLabel.hidden =
                        self.sharerSession.driverIdentifier != self.accountManager.registeredAccount!.identifier
                } else {
                    self.presentErrorAlert("Failed to fetch updated session")
                }
            })
        }
    }
    
    func showSharerLocationInMap(location: CLLocation, updateTime: NSDate) {
        if let sharerAnnotation = sharerAnnotation {
            // Location hasn't changed, so don't update the map
            if sharerAnnotation.coordinate == location.coordinate {
                return
            }
            
            mapView.removeAnnotation(sharerAnnotation)
        }
        
        let latDelta = CLLocationDegrees(0.01)
        let longDelta = CLLocationDegrees(0.01)
        
        let span = MKCoordinateSpanMake(latDelta, longDelta)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: true)
        
        let secondDifference = NSDate().timeIntervalSince1970 - updateTime.timeIntervalSince1970
        let minuteDifference = Int(secondDifference / 60)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = "\(sharerSession.sharerAccount.userAccount.fullName)'s Location"
        annotation.subtitle = "Last updated \(minuteDifference) minutes ago"
        self.mapView.addAnnotation(annotation)
        
        sharerAnnotation = annotation
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let destinationAnnotation = destinationAnnotation where annotation.coordinate == destinationAnnotation.coordinate {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: destinationPinIdentifier)
            pinAnnotationView.pinTintColor = UIColor.orangeColor()
            pinAnnotationView.canShowCallout = true
            return pinAnnotationView
        }
        if let sharerAnnotation = sharerAnnotation where annotation.coordinate == sharerAnnotation.coordinate {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: sharerPinIdentifier)
            pinAnnotationView.pinTintColor = UIColor.greenColor()
            pinAnnotationView.animatesDrop = true
            pinAnnotationView.canShowCallout = true
            return pinAnnotationView
        }
        return nil
    }
    
}
