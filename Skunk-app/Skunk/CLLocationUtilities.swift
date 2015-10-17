//
//  CLLocationUtilities.swift
//  Skunk
//
//  Created by Josh on 9/22/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocation {
    
    func serializeISO6709() -> String {
        return NSString(format: "%+lf,%+lf", self.coordinate.latitude, self.coordinate.longitude) as String
    }
    
}
