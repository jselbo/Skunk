//
//  ShareSessionTests.swift
//  Skunk
//
//  Created by Josh on 9/22/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import XCTest
@testable import Skunk

import CoreLocation

class ShareSessionTests: XCTestCase {
    
    func testSerializeForCreate_Time() {
        // April 21st, 1995 at 13:22:33 in GMT -5 time zone (EST)
        let date = NSDate(timeIntervalSince1970: 798488553)
        let receivers: Set<RegisteredUserAccount> = [createDummyAccount(123), createDummyAccount(456)]
        let session = ShareSession(sharerAccount: createDummyAccount(0), endCondition: .Time(date), needsDriver: true, receivers: receivers)
        
        let expected = [
            "receivers": [123, 456],
            "condition": [
                "type": "time",
                "data": "1995-04-21T13:22:33-05:00"
            ],
            "needs_driver": true
        ]
        XCTAssertEqual(session.serializeForCreate() as! [String : NSObject], expected)
    }
    
    func testSerializeForCreate_Location() {
        // Coordinates of Apple Headquarters
        let location = CLLocation(latitude: 37.331711, longitude: -122.030183)
        let session = ShareSession(sharerAccount: createDummyAccount(0), endCondition: .Location(location), needsDriver: false, receivers: [createDummyAccount(123)])
        
        let expected = [
            "receivers": [123],
            "condition": [
                "type": "location",
                "data": "+37.331711-122.030183"
            ],
            "needs_driver": false
        ]
        XCTAssertEqual(session.serializeForCreate() as! [String : NSObject], expected)
    }
    
    private func createDummyAccount(identifier: Uid) -> RegisteredUserAccount {
        let phoneNumber = PhoneNumber(text: "5551112222")!
        let account = UserAccount(firstName: "First", lastName: "Last", phoneNumber: phoneNumber)
        return RegisteredUserAccount(userAccount: account, identifier: identifier)
    }
    
}
