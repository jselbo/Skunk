//
//  CLLocationUtilities.swift
//  Skunk
//
//  Created by Josh on 9/22/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit
import CoreLocation

// For some reason this isn't included in CoreLocation...
public func ==(a: CLLocationCoordinate2D?, b: CLLocationCoordinate2D?) -> Bool {
    return a?.latitude == b?.latitude && a?.longitude == b?.longitude
}

public func -(a: CGPoint, b: CGPoint) -> CGPoint {
    return CGPointMake(a.x - b.x, a.y - b.y)
}

extension CLLocation {
    
    func serializeISO6709() -> String {
        return NSString(format: "%+lf,%+lf", self.coordinate.latitude, self.coordinate.longitude) as String
    }
    
}
