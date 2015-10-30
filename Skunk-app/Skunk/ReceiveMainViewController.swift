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
    var lastUpdatedTime: NSDate?
    
    @IBOutlet weak var optionsViewPanel: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var stopReceivingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = sharerSession.sharerAccount.userAccount.fullName
        
        mapView.userTrackingMode = .Follow
        
        switch sharerSession.endCondition {
        case .Location(let location):
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = "Destination"
            annotation.subtitle = "Session will end when sharer arrives here"
            
            mapView.addAnnotation(annotation)
            destinationAnnotation = annotation

        case .Time(_):
            break
        }
        
        conditionLabel.text = sharerSession.endCondition.humanizedString()
        
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
        
        sessionManager.sessionTermResponse(sharerSession, receiver: accountManager.registeredAccount!) { (success) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                spinner.removeFromSuperview()
                
                if success {
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
                    self.sharerSession.driverIdentifier = session.driverIdentifier
                    self.sharerSession.currentLocation = session.currentLocation
                    self.sharerSession.lastLocationUpdate = session.lastLocationUpdate
                    self.sharerSession.terminated = session.terminated
                    
                    if session.terminated {
                        self.presentErrorAlert("Your sharing session has ended.")
                        self.navigationController!.popViewControllerAnimated(true)
                        return
                    }
                    
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
        if lastUpdatedTime == updateTime {
            // Updated timestamp hasn't changed, so don't update the map
            return
        }
        lastUpdatedTime = updateTime
        
        // Remove existing pin because we are about to drop a new one
        // DEFECT #App1:  Nah this not needed 
        /*
        if let sharerAnnotation = sharerAnnotation {
            mapView.removeAnnotation(sharerAnnotation)
        }*/
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = "\(sharerSession.sharerAccount.userAccount.fullName)'s Location"
        
        var annotations: [MKAnnotation] = [annotation, mapView.userLocation]
        if let destinationAnnotation = destinationAnnotation {
            annotations.append(destinationAnnotation)
        }
        mapView.showAnnotations(annotations, animated: true)
        
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
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let sharerAnnotation = sharerAnnotation where sharerAnnotation.coordinate == view.annotation?.coordinate {
            // DEFECT #11: don't truncate seconds difference
            //let secondDifference = Int(NSDate().timeIntervalSince1970 - lastUpdatedTime!.timeIntervalSince1970)
            let secondDifference = NSDate().timeIntervalSince1970 - lastUpdatedTime!.timeIntervalSince1970
            
            let pointAnnotation = view.annotation! as! MKPointAnnotation
            pointAnnotation.subtitle = "Last updated \(secondDifference) second\(secondDifference == 1 ? "" : "s") ago"
        }
    }
    
}
