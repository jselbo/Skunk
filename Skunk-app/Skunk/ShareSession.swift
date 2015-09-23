//
//  ShareSession.swift
//  Skunk
//
//  Created by Josh on 9/21/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit
import CoreLocation

enum RequestState {
    /// No request has been made.
    case None
    /// The request has been made but no user has accepted yet.
    case Requested
    /// The given user has accepted the request.
    case Accepted(Uid)
}

enum ShareEndCondition {
    case Location(CLLocation)
    case Time(NSDate)
}

class ReceiverInfo: NSObject {
    let identifier: Uid
    /// Sharer can request to stop sharing location with individual receivers.
    let stopSharingState = RequestState.None
    
    init(identifier: Uid) {
        self.identifier = identifier
    }
}

/// Class that contains and manages all information for a given sharing session.
class ShareSession: NSObject {
    let endCondition: ShareEndCondition
    let needsDriver: Bool
    
    /// Set of users with whom this user's location is being shared
    var receivers: Set<ReceiverInfo>
    
    /// Current state of the driver request. Only changed if `needsDriver` is `true`.
    var currentDriverState = RequestState.None
    /// Current state of the pickup request. Only changed if `needsDriver` is `true`.
    var currentPickupState = RequestState.None
    
    /// ETA given by the accepting driver. Only set if a pickup request has been made and accepted.
    var driverEstimatedArrival: NSDate?
    
    /// This device's last recorded location.
    var currentLocation: CLLocation?
    var lastLocationUpdate: NSDate?
    
    init(endCondition: ShareEndCondition, needsDriver: Bool, receivers: Set<Uid>) {
        self.endCondition = endCondition
        self.needsDriver = needsDriver
        self.receivers = Set(receivers.map { id in ReceiverInfo(identifier: id) })
        
        if needsDriver {
            currentDriverState = .Requested
        }
    }
}
