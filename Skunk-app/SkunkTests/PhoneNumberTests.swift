//
//  PhoneNumberTests.swift
//  Skunk
//
//  Created by Josh on 9/24/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import XCTest
@testable import Skunk

class PhoneNumberTests: XCTestCase {
    
    func testInit_GoodPhone() {
        let phone = PhoneNumber(text: "(555) 111-2222")
        XCTAssertNotNil(phone)
    }
    
    func testInit_BadPhone() {
        let phone = PhoneNumber(text: "(555) 11-2222")
        XCTAssertNil(phone)
    }
    
    func testInit_NilOrEmptyPhone() {
        let phone1 = PhoneNumber(text: nil)
        XCTAssertNil(phone1)
        
        let phone2 = PhoneNumber(text: "")
        XCTAssertNil(phone2)
    }
    
}
