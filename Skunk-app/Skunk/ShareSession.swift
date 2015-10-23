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
    case Accepted
}

enum ShareEndCondition: Serializable {
    case Location(CLLocation)
    case Time(NSDate)
    
    func name() -> String {
        switch (self) {
        case .Location(_):
            return "location"
        case .Time(_):
            return "time"
        }
    }
    
    func serialize() -> AnyObject {
        return [
            "type": name(),
            "data": serializeData()
        ]
    }
    
    private func serializeData() -> AnyObject {
        switch (self) {
        case .Location(let location):
            return location.serializeISO6709()
        case .Time(let date):
            return date.serializeISO8601()
        }
    }
}

class ReceiverInfo: NSObject {
    let account: RegisteredUserAccount
    /// Sharer can request to stop sharing location with individual receivers.
    // TODO: defect this was a let
    var stopSharingState = RequestState.None
    
    init(account: RegisteredUserAccount) {
        self.account = account
    }
}

/// Class that contains and manages all information for a given sharing session.
class ShareSession: NSObject {
    let sharerAccount: RegisteredUserAccount
    let endCondition: ShareEndCondition
    let needsDriver: Bool
    
    /// Unique identifier for this session, assigned by the server.
    var identifier: Sid?
    
    /// Set of users with whom this user's location is being shared
    var receivers: Set<ReceiverInfo>
    
    /// User ID of the driver who has accepted the driver request.
    /// Only non-nil if `needsDriver` is `true` and a driver has accepted.
    // TODO document defect (used to be RequestState but no ==)
    var driverIdentifier: Uid?
    
    /// ETA given by the accepting driver. Only set if a pickup request has been made and accepted.
    var driverEstimatedArrival: NSDate?
    
    /// This device's last recorded location.
    var currentLocation: CLLocation?
    var lastLocationUpdate: NSDate?
    
    init(sharerAccount: RegisteredUserAccount,
        endCondition: ShareEndCondition,
        needsDriver: Bool,
        receivers: Set<RegisteredUserAccount>) {
        self.sharerAccount = sharerAccount
        self.endCondition = endCondition
        self.needsDriver = needsDriver
        self.receivers = Set(receivers.map { account in ReceiverInfo(account: account) })
    }
    
    func findReceiver(identifier: Uid) -> ReceiverInfo? {
        for receiver in receivers {
            if receiver.account.identifier == identifier {
                return receiver
            }
        }
        return nil
    }
    
    // On create, we haven't been assigned an identifier yet.
    func serializeForCreate() -> AnyObject {
        let receiverIDs = receivers
            // Uint64 are not directly castable to NSNumber, so we must
            // initialize with NSNumber explicitly. This is necessary to cast to NSDictionary -> AnyObject
            .map { r in NSNumber(unsignedLongLong: r.account.identifier) }
            // Also sort for deterministic order during testing.
            .sort { r1, r2 in r1.unsignedLongLongValue < r2.unsignedLongLongValue }
        
        return [
            "receivers": receiverIDs,
            "condition": endCondition.serialize(),
            "needs_driver": needsDriver
        ]
    }
    
    func serializeForUpdate() -> AnyObject {
        return [
            "location": currentLocation!.serializeISO6709()
        ]
    }
}
