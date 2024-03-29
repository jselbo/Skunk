//
//  ServerRequest.swift
//  Skunk
//
//  Created by Josh on 9/28/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import Foundation

enum RequestType: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
}

enum ResponseFailure: Equatable {
    case ServerError(NSError?)
    case UnexpectedStatusCode(Int)
    case UnexpectedContentType(AnyObject?)
    case DeserializeJSONError(data: NSData?)
}

func ==(a: ResponseFailure, b: ResponseFailure) -> Bool {
    switch (a, b) {
    case (.ServerError(let a), .ServerError(let b)) where a == b:
        return true
    case (.UnexpectedStatusCode(let a), .UnexpectedStatusCode(let b)) where a == b:
        return true
    case (.UnexpectedContentType(_), .UnexpectedContentType(_)):
        return true
    case (.DeserializeJSONError(let a), .DeserializeJSONError(let b)) where a == b:
        return true
    default:
        return false
    }
}

/// Returns equality of two possibly nil JSON objects
/// (Returned by NSJSONSerialization.JSONObjectWithData)
func JSONEquals(a: AnyObject?, _ b: AnyObject?) -> Bool {
    if a == nil && b == nil {
        return true
    }
    if let a = a as? [NSObject], b = b as? [NSObject] {
        return a == b
    }
    if let a = a as? [String: NSObject], b = b as? [String: NSObject] {
        return a == b
    }
    return false
}

func ==(a: ServerResponse, b: ServerResponse) -> Bool {
    switch (a, b) {
    case (.Success(let a), .Success(let b)):
        return JSONEquals(a, b)
    case (.Failure(let a), .Failure(let b)) where a == b:
        return true
    default:
        return false
    }
}

enum ServerResponse: Equatable {
    /// Type of `response` is guaranteed by `ResponseBodyType`
    case Success(response: AnyObject?)
    case Failure(ResponseFailure)
}

enum ResponseBodyType {
    /// Returned response guaranteed to be `nil`
    case None
    /// Returned response guaranteed to be of type `[AnyObject]`
    case JSONArray
    /// Returned response guaranteed to be of type `[String: AnyObject]`
    case JSONObject
}

enum ContentType: String {
    case HTML = "text/html"
    case JSON = "application/json"
}

class ServerRequest: NSObject {
    
    let type: RequestType
    let url: NSURL
    
    var expectedStatusCode = Constants.statusOK
    var expectedBodyType = ResponseBodyType.None
    var expectedContentType: ContentType?
    var additionalHTTPHeaders = [NSObject: AnyObject]()
    
    private var contentType: ContentType?
    private var JSONParams: AnyObject?
    
    private var currentTask: NSURLSessionTask!
    
    init(type: RequestType, url: NSURL) {
        self.type = type
        self.url = url
    }
    
    func execute(completion: (ServerResponse) -> Void) -> NSURLSessionTask {
        return executeQuery(nil, completion: completion)
    }
    
    func execute(JSONParams: AnyObject, completion: (response: ServerResponse) -> Void) -> NSURLSessionTask {
        let data: NSData
        do {
            data = try NSJSONSerialization.dataWithJSONObject(JSONParams, options: NSJSONWritingOptions())
        } catch {
            // JSON serialization should not fail
            NSException(name: "Serialization Exception",
                reason: "Failed to serialize parameters: \(JSONParams)", userInfo: nil).raise()
            return NSURLSessionTask()
        }
        
        self.JSONParams = JSONParams
        contentType = .JSON
        return executeQuery(data, completion: completion)
    }
    
    func logResponseFailure(failure: ResponseFailure) {
        var message: String
        switch (failure) {
        case .ServerError(let error):
            message = "Server error: \(error)"
            break
        case .UnexpectedStatusCode(let statusCode):
            message = "Unexpected status code: \(statusCode), expected \(expectedStatusCode)"
            break
        case .UnexpectedContentType(let type):
            message = "Unexpected content type: \(type), expected \(expectedContentType?.rawValue)"
            break
        case .DeserializeJSONError(let data):
            message = "JSON deserialization error for data: \(data)"
            break
        }
        
        let fullMessage = "\(message),\n\tfor \(type.rawValue) request to \(url.absoluteString) with params: \(JSONParams), HTTP headers: \(currentTask.currentRequest?.allHTTPHeaderFields)"
        print(fullMessage)
    }
    
    private func executeQuery(bodyData: NSData?, completion: (ServerResponse) -> Void) -> NSURLSessionTask {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        var HTTPHeaders = additionalHTTPHeaders
        if let expectedContentType = expectedContentType {
            HTTPHeaders["Accept"] = expectedContentType.rawValue
        }
        if let contentType = contentType {
            HTTPHeaders["Content-Type"] = contentType.rawValue
        }
        config.HTTPAdditionalHeaders = HTTPHeaders
        
        let session = NSURLSession(configuration: config)
        let request = NSMutableURLRequest(
            URL: url,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: Constants.serverTimeout)
        request.HTTPMethod = type.rawValue
        request.HTTPBody = bodyData
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            let handledResponse = self.handleServerResponse(data, response: response, error: error)
            completion(handledResponse)
        }
        currentTask = task
        task.resume()
        return task
    }
    
    /// Returns the server JSON response, if possible. Otherwise returns nil.
    private func handleServerResponse(data: NSData?, response: NSURLResponse?, error: NSError?) -> ServerResponse {
        // Verify we received expected status with no error
        guard error == nil else {
            return .Failure(.ServerError(error))
        }
        
        // We should only be getting HTTP responses
        let httpResponse = response as! NSHTTPURLResponse
        
        // Verify status code
        guard httpResponse.statusCode == expectedStatusCode else {
            return .Failure(.UnexpectedStatusCode(httpResponse.statusCode))
        }
        
        // Verify declared content type
        let contentType = httpResponse.allHeaderFields["Content-Type"]
        guard contentType as? String == expectedContentType?.rawValue else {
            return .Failure(.UnexpectedContentType(contentType))
        }
        
        switch (expectedBodyType) {
        case .None:
            // Doesn't enforce that the response body is nil.
            return .Success(response: nil)
        case .JSONArray:
            guard let data = data else {
                return .Failure(.DeserializeJSONError(data: nil))
            }
            guard let parsedJSONArray = parseJSON(data) as? [AnyObject] else {
                return .Failure(.DeserializeJSONError(data: data))
            }
            
            return .Success(response: parsedJSONArray)
        case .JSONObject:
            guard let data = data else {
                return .Failure(.DeserializeJSONError(data: nil))
            }
            guard let parsedJSONObject = parseJSON(data) as? [String: AnyObject] else {
                return .Failure(.DeserializeJSONError(data: data))
            }
            
            return .Success(response: parsedJSONObject)
        }
    }
    
    private func parseJSON(data: NSData) -> AnyObject? {
        do {
            let JSONData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
            return JSONData
        } catch {}
        return nil
    }
    
}
