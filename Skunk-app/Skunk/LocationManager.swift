//
//  LocationManager.swift
//  Skunk
//
//  Created by Josh on 10/8/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import Foundation
import MapKit

@objc protocol LocationManagerDelegate: NSObjectProtocol {
    optional func locationManager(manager: LocationManager, didUpdateLocation location: CLLocation)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    var manager: CLLocationManager!
    var delegate: LocationManagerDelegate?
    
    private var authorizationCompletion: ((authorized: Bool) -> Void)?
    
    override init() {
        super.init()
        
        manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
    }
    
    func requestAuthorizationIfNotAuthorized(completion: (authorized: Bool) -> Void) {
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            // Already authorized
            completion(authorized: true)
            
        case .NotDetermined:
            // First attempt to authorize
            
            // Call completion handler in locationManager:didChangeAuthorizationStatus:
            authorizationCompletion = completion
            manager.requestAlwaysAuthorization()
            
        case .Denied:
            // User has denied us permission
            completion(authorized: false)

        case .Restricted:
            // Not sure when this could happen
            print("CLLocationManager authorization status restricted.")
            completion(authorized: false)
            
        case .AuthorizedWhenInUse:
            // The app should never have asked for in-use authorization, so this is fatal
            NSException(name: "Invalid Auth Status", reason: "AuthorizedWhenInUse cannot happen", userInfo: nil).raise()
        }
    }
    
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if let authorizationCompletion = authorizationCompletion {
            authorizationCompletion(authorized: status == .AuthorizedAlways)
            self.authorizationCompletion = nil
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else {
            return
        }
        
        delegate?.locationManager?(self, didUpdateLocation: lastLocation)
    }
    
}
