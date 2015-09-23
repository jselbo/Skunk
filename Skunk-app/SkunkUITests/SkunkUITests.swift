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
    
    func testAppFlow() {
        let app = XCUIApplication()
        XCTAssert(app.buttons["beginSharingButton"].exists)
        app.buttons["beginSharingButton"].tap()
        XCTAssert(app.buttons["selectFriendsButton"].exists)
        app.buttons["selectFriendsButton"].tap()
        XCTAssert(app.navigationBars["Select Friends"].buttons["Done"].exists)
        app.navigationBars["Select Friends"].buttons["Done"].tap()
        XCTAssert( app.buttons["stopSharingButton"].exists )
    }
}
