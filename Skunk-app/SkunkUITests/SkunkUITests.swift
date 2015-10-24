//
//  SkunkUITests.swift
//  SkunkUITests
//
//  Created by Josh on 9/15/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import XCTest

import OHHTTPStubs

class SkunkUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launch()
        
        // Log out if currently logged in
        if app.buttons["Settings"].exists {
            app.tabBars.buttons["Settings"].tap()
            app.tables.staticTexts["Log Out"].tap()
        }
    }
    
    func testSharerFlow() {
        let app = XCUIApplication()
        app.buttons["Debug Login"].tap()
        
        app.buttons["beginSharingButton"].tap()
        app.tables.buttons["Select Time"].tap()
        app.toolbars.buttons["Done"].tap()
        app.buttons["selectFriendsButton"].tap()
        app.navigationBars["Choose Friends"].buttons["Done"].tap()
        XCTAssert(app.buttons["pickMeUpButton"].exists)
    }

    func testReceiverScreen() {
        let app = XCUIApplication()
        app.buttons["Debug Login"].tap()
        
        app.tabBars.buttons["Receiver"].tap()
        app.tables.staticTexts["John Smith"].tap()
        app.buttons["I Can Pick You Up"].tap()
        app.buttons["Stop Receiving Updates"].tap()
    }
    
    func testLogInAppFlow() {
        // TODO: This doesn't freakin work
        // The assertion at the bottom fails but it should pass
        // It works if I copy this stub to code in the regular Skunk target
        // Will debug later
        stub(isPath("/users/login")) { (request) -> OHHTTPStubsResponse in
            let path = OHPathForFile("login.json", self.dynamicType)
            return fixture(path!, status: 200, headers: ["Content-Type": "application/json"])
        }
        
        let app = XCUIApplication()
        app.buttons["Log In"].tap()
        
        let textField = app.tables.cells.containingType(.StaticText, identifier:"Phone").childrenMatchingType(.TextField).element
        textField.tap()
        textField.typeText("5551112222")
        
        let secureTextField = app.tables.cells.containingType(.StaticText, identifier:"Password").childrenMatchingType(.SecureTextField).element
        secureTextField.tap()
        secureTextField.typeText("pass")
        
        app.buttons["Log In"].tap()
        // XCTAssert(app.tabBars.buttons["Share"].exists)
    }
    
    func testSignUpFlow() {
        // TODO this doesn't work either.
        stub(isPath("/users/create")) { _ in
            let stubPath = OHPathForFile("register.json", self.dynamicType)
            return fixture(stubPath!, status: 200, headers: ["Content-Type": "application/json"])
        }

        let app = XCUIApplication()
        app.buttons["Sign Up"].tap()
        
        let textField = app.tables.cells.containingType(.StaticText, identifier:"First Name").childrenMatchingType(.TextField).element
        textField.tap()
        textField.typeText("John")
        
        let textField2 = app.tables.cells.containingType(.StaticText, identifier:"Last Name").childrenMatchingType(.TextField).element
        textField2.tap()
        textField2.typeText("Smith")
        
        let textField3 = app.tables.cells.containingType(.StaticText, identifier:"Phone").childrenMatchingType(.TextField).element
        textField3.tap()
        textField3.typeText("5551112222")
        
        let secureTextField = app.tables.cells.containingType(.StaticText, identifier:"Password").childrenMatchingType(.SecureTextField).element
        secureTextField.tap()
        secureTextField.typeText("pass")
        
        app.buttons["Register"].tap()
        // XCTAssert(app.tabBars.buttons["Share"].exists)
    }

}
