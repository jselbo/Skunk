//
//  UserAccountManager.swift
//  Skunk
//
//  Created by Josh on 9/23/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import Foundation
import Security

enum UserAccountManagerError: ErrorType {
    case DefaultsSynchronize
    case KeychainSave(OSStatus, NSData)
    case KeychainDelete(OSStatus)
}

class UserAccountManager: NSObject {
    
    private(set) var registeredAccount: RegisteredUserAccount?
    
    override init() {
        super.init()
        
        let account = loadAccount()
        let userIdentifier = loadUserIdentifier()
        if let account = account, userIdentifier = userIdentifier {
            registeredAccount = RegisteredUserAccount(userAccount: account, identifier: userIdentifier)
        }
    }
    
    /// If login request succeeds, returns the RegisteredUserAccount associated with this user's phone and password.
    /// Otherwise, returns nil.
    func logInWithCredentials(phone: PhoneNumber, password: String, completion: (registeredAccount: RegisteredUserAccount?) -> ()) {
        let params = [
            "phone": phone.serialize(),
            "password": password,
        ]
        
        let request = ServerRequest(type: .POST, url: Constants.Endpoints.usersLoginURL)
        request.expectedContentType = .JSON
        request.expectedBodyType = .JSONObject
        request.execute(params) { (response) -> Void in
            switch (response) {
            case .Success(let response):
                let JSONResponse = response as! [String: AnyObject]
                
                guard let firstName = JSONResponse["firstName"] as? String,
                    lastName = JSONResponse["lastName"] as? String,
                    identifierString = JSONResponse["userID"] as? String,
                    identifier = Uid(identifierString)
                else {
                    print("Error: Failed to parse values from JSON: \(JSONResponse)")
                    completion(registeredAccount: nil)
                    break
                }
                
                let account = UserAccount(firstName: firstName, lastName: lastName,
                    phoneNumber: phone, password: password)
                let registered = RegisteredUserAccount(userAccount: account, identifier: identifier)
                completion(registeredAccount: registered)
                
            case .Failure(let failure):
                request.logResponseFailure(failure)
                completion(registeredAccount: nil)
            }
        }
    }
    
    /// If register request succeeds, returns a RegisteredUserAccount object with the newly assigned user identifier
    /// given by the server. Otherwise, returns nil.
    func registerAccount(account: UserAccount, completion: (registeredAccount: RegisteredUserAccount?) -> ()) {
        let params = [
            "firstName": account.firstName,
            "lastName": account.lastName,
            "phone": account.phoneNumber.serialize(),
            "password": account.password!,
        ]
        
        let request = ServerRequest(type: .POST, url: Constants.Endpoints.usersCreateURL)
        request.expectedContentType = .JSON
        request.expectedBodyType = .JSONObject
        request.execute(params) { (response) -> Void in
            switch (response) {
            case .Success(let response):
                let JSONResponse = response as! [String: AnyObject]
                
                guard let identifierString = JSONResponse["userID"] as? String, identifier = Uid(identifierString) else {
                    print("Error: Failed to parse values from JSON: \(JSONResponse)")
                    completion(registeredAccount: nil)
                    break
                }
                
                let registered = RegisteredUserAccount(userAccount: account, identifier: identifier)
                completion(registeredAccount: registered)
                
            case .Failure(let failure):
                request.logResponseFailure(failure)
                completion(registeredAccount: nil)
            }
        }
    }
    
    func saveRegisteredAccount(account: RegisteredUserAccount) throws {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(account.userAccount.firstName, forKey: Constants.keyFirstName)
        defaults.setObject(account.userAccount.lastName, forKey: Constants.keyLastName)
        defaults.setObject(account.userAccount.phoneNumber.sanitizedText, forKey: Constants.keyPhoneNumber)
        guard defaults.synchronize() else {
            throw UserAccountManagerError.DefaultsSynchronize
        }
        
        try savePassword(account.userAccount.password!)
        try saveUserIdentifier(account.identifier)
        
        registeredAccount = account
    }
    
    /// Deletes all stored account credentials on this device.
    func clearCredentials() throws {
        // Clear user defaults
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(Constants.keyFirstName)
        defaults.removeObjectForKey(Constants.keyLastName)
        defaults.removeObjectForKey(Constants.keyPhoneNumber)
        guard defaults.synchronize() else {
            throw UserAccountManagerError.DefaultsSynchronize
        }
        
        // Clear keychain data
        try deleteFromKeychain(Constants.userIdentifierService)
        try deleteFromKeychain(Constants.userPasswordService)
    }
    
    private func loadAccount() -> UserAccount? {
        let defaults = NSUserDefaults()
        if let
            firstName = defaults.objectForKey(Constants.keyFirstName) as? String,
            lastName = defaults.objectForKey(Constants.keyLastName) as? String,
            phone = PhoneNumber(text: defaults.objectForKey(Constants.keyPhoneNumber) as? String),
            pass = loadPassword() {
                
            return UserAccount(firstName: firstName, lastName: lastName, phoneNumber: phone, password: pass)
        }
        return nil
    }
    
    private func savePassword(password: String) throws {
        let passwordData = password.dataUsingEncoding(NSUTF8StringEncoding)!
        try saveToKeychain(Constants.userPasswordService, data: passwordData)
    }
    
    private func loadPassword() -> String? {
        if let resultData = loadFromKeychain(Constants.userPasswordService) {
            return String(data: resultData, encoding: NSUTF8StringEncoding)
        }
        return nil
    }
    
    private func saveUserIdentifier(var identifier: Uid) throws {
        let identifierData = NSData(bytes: &identifier, length: sizeof(Uid))
        try saveToKeychain(Constants.userIdentifierService, data: identifierData)
    }
    
    private func loadUserIdentifier() -> Uid? {
        if let resultData = loadFromKeychain(Constants.userIdentifierService) {
            var identifier: Uid = 0
            resultData.getBytes(&identifier, length: sizeof(Uid))
            return identifier
        }
        return nil
    }
    
    private func saveToKeychain(service: String, data: NSData) throws {
        let saveQuery = [
            kSecClass as NSString: kSecClassGenericPassword,
            kSecAttrService as NSString: service,
            kSecValueData as NSString: data,
        ]
        
        // We don't care if delete fails
        SecItemDelete(saveQuery)
        
        let saveStatus = SecItemAdd(saveQuery, nil)
        guard saveStatus == errSecSuccess else {
            throw UserAccountManagerError.KeychainSave(saveStatus, data)
        }
    }
    
    private func loadFromKeychain(service: String) -> NSData? {
        let loadQuery: [NSString: AnyObject] = [
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: kCFBooleanTrue,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecAttrService: service,
        ]
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(&result, { SecItemCopyMatching(loadQuery, $0) })
        if status == errSecSuccess {
            return result as? NSData
        }
        
        return nil
    }
    
    private func deleteFromKeychain(service: String) throws {
        let deleteQuery = [
            kSecClass as NSString: kSecClassGenericPassword,
            kSecAttrService as NSString: service,
        ]
        
        let deleteStatus = SecItemDelete(deleteQuery)
        guard deleteStatus == errSecSuccess else {
            throw UserAccountManagerError.KeychainDelete(deleteStatus)
        }
    }
}