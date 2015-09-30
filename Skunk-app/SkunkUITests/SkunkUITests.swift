//
//  SkunkUITests.swift
//  SkunkUITests
//
//  Created by Josh on 9/15/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import XCTest

class SkunkUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSharerFlow() {
        let app = XCUIApplication()
        if !app.buttons["beginSharingButton"].exists {
            app.buttons["Debug Login"].tap()
        }
        XCTAssert(app.buttons["beginSharingButton"].exists)
        app.buttons["beginSharingButton"].tap()
        XCTAssert(app.buttons["selectFriendsButton"].exists)
        app.buttons["selectFriendsButton"].tap()
        XCTAssert(app.navigationBars["Select Friends"].buttons["Done"].exists)
        app.navigationBars["Select Friends"].buttons["Done"].tap()
        XCTAssert( app.buttons["stopSharingButton"].exists )

    }

    func testReceiverScreen() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        if !app.buttons["beginSharingButton"].exists {
            app.buttons["Debug Login"].tap()
        }
        app.tabBars.buttons["Receiver"].tap()
        app.tables.staticTexts["John Smith"].tap()
        app.buttons["I Can Pick You Up"].tap()
        app.buttons["Stop Receiving Updates"].tap()
    }
    func testLogInAppFlow() {
        //TODO: Once App Server connection is functional recreate the tests with dummy useres to ensure correct login
        let app = XCUIApplication()
        if !app.buttons["Log In"].exists {
            app.tabBars.buttons["Settings"].tap()
            app.tables.staticTexts["Log Out"].tap()
        }
        XCUIApplication().buttons["Log In"].tap()
        XCTAssert( app.buttons["Log In"].exists )
        
    }
    func testSignUpFlow() {
        //TODO: Once App Server connection is functional recreate the tests with dummy useres to ensure correct SignUp
        let app = XCUIApplication()
        if !app.buttons["Log In"].exists {
            app.tabBars.buttons["Settings"].tap()
            app.tables.staticTexts["Log Out"].tap()
        }
        XCUIApplication().buttons["Sign Up"].tap()
        XCTAssert(app.buttons["Register"].exists)
    }

}
