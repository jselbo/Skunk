//
//  UserAccountManagerTests.swift
//  Skunk
//
//  Created by Josh on 9/23/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import XCTest
@testable import Skunk

import Security

class UserAccountManagerTests: XCTestCase {
    
    override func tearDown() {
        // Clear credentials between test instances
        let manager = UserAccountManager()
        do {
            try manager.clearCredentials()
        } catch {
            // Deletion fails if we don't save credentials in a test case -
            // we don't really care if that happens
        }
    }
    
    func testInit_FirstLaunch() {
        let manager = UserAccountManager()
        XCTAssertNil(manager.registeredAccount)
    }
    
    func testInit_AfterSave() {
        // Simulate save account credentials
        let phone = PhoneNumber(text: "5551112222")!
        let account = UserAccount(firstName: "John", lastName: "Smith", phoneNumber: phone, password: "pass")
        let registeredAccount = RegisteredUserAccount(userAccount: account, identifier: 12345)
        
        let firstManager = UserAccountManager()
        try! firstManager.saveRegisteredAccount(registeredAccount)
        
        let secondManager = UserAccountManager()
        let loadedAccount = secondManager.registeredAccount
        XCTAssertNotNil(loadedAccount)
        XCTAssertEqual("John", loadedAccount?.userAccount.firstName)
        XCTAssertEqual("Smith", loadedAccount?.userAccount.lastName)
        XCTAssertEqual("5551112222", loadedAccount?.userAccount.phoneNumber.sanitizedText)
        XCTAssertEqual("pass", loadedAccount?.userAccount.password)
        XCTAssertEqual(12345, loadedAccount?.identifier)
    }
    
}
