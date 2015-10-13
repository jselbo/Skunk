//
//  ServerRequestTests.swift
//  Skunk
//
//  Created by Josh on 10/1/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import XCTest
@testable import Skunk

import CFNetwork
import OHHTTPStubs

class ServerRequestTests: XCTestCase {
    
    let testURL = NSURL(string: "http://example.com")!
    
    // MARK: - ServerResponse.Success tests
    
    func testExecute_defaultStatus() {
        stub(isHost("example.com")) { _ in
            let stubPath = OHPathForFile("empty.json", self.dynamicType)
            return fixture(stubPath!, status: 200, headers: ["Content-Type": "text/html"])
        }
        
        let request = ServerRequest(type: .GET, url: testURL)
        expectExecute(request, expected: .Success(response: nil))
    }
    
    func testExecute_JSONArray() {
        stub(isHost("example.com")) { _ in
            let stubPath = OHPathForFile("array.json", self.dynamicType)
            return fixture(stubPath!, status: 200, headers: ["Content-Type": "application/json"])
        }
        
        let request = ServerRequest(type: .GET, url: testURL)
        request.expectedBodyType = .JSONArray
        request.expectedContentType = .JSON
        let expected = [ 100, 200 ]
        expectExecute(request, expected: .Success(response: expected))
    }
    
    func testExecute_JSONObject() {
        stub(isHost("example.com")) { _ in
            let stubPath = OHPathForFile("object.json", self.dynamicType)
            return fixture(stubPath!, status: 200, headers: ["Content-Type": "application/json"])
        }
        
        let request = ServerRequest(type: .GET, url: testURL)
        request.expectedBodyType = .JSONObject
        request.expectedContentType = .JSON
        let expected = [ "abc": 123, "def": 456 ]
        expectExecute(request, expected: .Success(response: expected))
    }
    
    // MARK: - ServerResponse.Failure tests
    
    func testExecute_unexpectedStatus() {
        // Expect status 200 but return 300
        stub(isHost("example.com")) { _ in
            let stubPath = OHPathForFile("empty.json", self.dynamicType)
            return fixture(stubPath!, status: 300, headers: ["Content-Type": "text/html"])
        }
        
        let request = ServerRequest(type: .GET, url: testURL)
        request.expectedStatusCode = Constants.statusOK
        let failure = ResponseFailure.UnexpectedStatusCode(300)
        expectExecute(request, expected: .Failure(failure))
    }
    
    func testExecute_unexpectedContentType() {
        // Expect default text/html content type, but return application/json
        stub(isHost("example.com")) { _ in
            let stubPath = OHPathForFile("empty.json", self.dynamicType)
            return fixture(stubPath!, status: 200, headers: ["Content-Type": "application/json"])
        }
        
        let request = ServerRequest(type: .GET, url: testURL)
        let failure = ResponseFailure.UnexpectedContentType("application/json")
        expectExecute(request, expected: .Failure(failure))
    }
    
    func testExecute_deserializationFailure_invalid() {
        // Return invalid JSON
        stub(isHost("example.com")) { _ in
            let stubPath = OHPathForFile("invalid.json", self.dynamicType)
            return fixture(stubPath!, status: 200, headers: ["Content-Type": "application/json"])
        }
        
        let request = ServerRequest(type: .GET, url: testURL)
        request.expectedContentType = .JSON
        request.expectedBodyType = .JSONObject
        let badJSONData = "invalid".dataUsingEncoding(NSUTF8StringEncoding)
        let failure = ResponseFailure.DeserializeJSONError(data: badJSONData)
        expectExecute(request, expected: .Failure(failure))
    }
    
    func testExecute_deserializationFailure_array() {
        // Expect JSON object but return array
        stub(isHost("example.com")) { _ in
            let stubPath = OHPathForFile("array.json", self.dynamicType)
            return fixture(stubPath!, status: 200, headers: ["Content-Type": "application/json"])
        }
        
        let request = ServerRequest(type: .GET, url: testURL)
        request.expectedContentType = .JSON
        request.expectedBodyType = .JSONObject
        let badJSONData = "[100, 200]".dataUsingEncoding(NSUTF8StringEncoding)
        let failure = ResponseFailure.DeserializeJSONError(data: badJSONData)
        expectExecute(request, expected: .Failure(failure))
    }
    
    func testExecute_deserializationFailure_object() {
        // Expected JSON array but return object
        stub(isHost("example.com")) { _ in
            let stubPath = OHPathForFile("object.json", self.dynamicType)
            return fixture(stubPath!, status: 200, headers: ["Content-Type": "application/json"])
        }
        
        let request = ServerRequest(type: .GET, url: testURL)
        request.expectedContentType = .JSON
        request.expectedBodyType = .JSONArray
        let badJSONData = "{\"abc\": 123, \"def\": 456}".dataUsingEncoding(NSUTF8StringEncoding)
        let failure = ResponseFailure.DeserializeJSONError(data: badJSONData)
        expectExecute(request, expected: .Failure(failure))
    }
    
    func testExecute_serverError() {
        // Return server error
        let error = NSError(domain: NSURLErrorDomain,
            code: Int(CFNetworkErrors.CFURLErrorCannotConnectToHost.rawValue),
            userInfo: nil)
        stub(isHost("example.com")) { _ in
            return OHHTTPStubsResponse(error: error)
        }
        
        let request = ServerRequest(type: .GET, url: testURL)
        let failure = ResponseFailure.ServerError(error)
        expectExecute(request, expected: .Failure(failure))
    }
    
    // MARK: - Helper methods
    
    private func expectExecute(request: ServerRequest, expected: ServerResponse) {
        // Use XCTestExpectation to block while waiting for response callback to execute and assert equality.
        let expectation = self.expectationWithDescription("Mocked network response callback")
        let task = request.execute { (response: ServerResponse) -> Void in
            XCTAssertEqual(expected, response)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(1.0) { error in
            if let error = error {
                print("Error waiting for callback: \(error.localizedDescription)")
            }
            task.cancel()
        }
    }
    
}
