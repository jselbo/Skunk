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
    
    func AppFlow() {
        let app = XCUIApplication()
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
        
        app.tabBars.buttons["Receiver"].tap()
        
        app.tables.staticTexts["John Smith"].tap()
        
        app.buttons["I Can Pick You Up"].tap()
        
        app.buttons["Stop Receiving Updates"].tap()
    }
    func testLogInAppFlow() {
        let app = XCUIApplication()
        app.buttons["Log In"].tap()
        
        let tablesQuery = app.tables
        let textField = tablesQuery.cells.containingType(.StaticText, identifier:"Phone").childrenMatchingType(.TextField).element
        textField.tap()
        textField.typeText("2035128322")
        
        let secureTextField = tablesQuery.cells.containingType(.StaticText, identifier:"Password").childrenMatchingType(.SecureTextField).element
        secureTextField.tap()
        secureTextField.typeText("password")
        tablesQuery.buttons["Log In"].tap()
        XCTAssert(app.buttons["beginSharingButton"].exists)
        AppFlow()
    }
    func testSignUp() {
        //TODO
    }
}
