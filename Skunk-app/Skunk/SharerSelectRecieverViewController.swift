//
//  SharerSelectRecieverViewController.swift
//  Skunk
//
//  Created by Don Phan on 9/23/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit
import Contacts

import MBProgressHUD

class SharerSelectRecieverViewController: UITableViewController {
    
    var endCondition: ShareEndCondition!
    var needsDriver: Bool!
    var accountManager: UserAccountManager!
    var locationManager: LocationManager!
    var sessionManager: ShareSessionManager!
    var session: ShareSession!
    
    let contactStore = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sessionManager = ShareSessionManager(account: accountManager.registeredAccount!)
        
        requestAuthContacts { accessGranted in
            if accessGranted {
                self.readContacts({ (phoneNumbers) -> Void in
                    if let phoneNumbers = phoneNumbers {
                        print("numbers: \(phoneNumbers)")
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { _ in
                            self.presentErrorAlert("Failed to read contacts from address book.")
                        })
                    }
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { _ in
                    self.presentErrorAlert(Constants.needContactsAuthorizationMessage)
                })
            }
        }
    }

    // Auth To Use Address Book
    private func requestAuthContacts( completionHandler: (accessGranted: Bool) -> Void ) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        switch authorizationStatus {
        case .Authorized:
            completionHandler(accessGranted: true)
        case .NotDetermined:
            // First attempt to authorize
            contactStore.requestAccessForEntityType(.Contacts, completionHandler: { access, accessError in
                if let accessError = accessError {
                    print("Access error: \(accessError.localizedDescription)")
                }
                completionHandler(accessGranted: access)
            })
        case .Denied:
            // User denied authorization before
            completionHandler(accessGranted: false)
        case .Restricted:
            print("CNContactStore authorization status Restricted")
            completionHandler(accessGranted: false)
        }
    }
    
    // Read address book contacts. Call this off the main thread.
    // At this point it is assumed authorization has been granted by user.
    func readContacts(completion: (phoneNumbers: Set<PhoneNumber>?) -> Void) {
        let keys = [CNContactGivenNameKey, CNContactPhoneNumbersKey]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
        do {
            var phoneNumbers = Set<PhoneNumber>()
            
            try contactStore.enumerateContactsWithFetchRequest(fetchRequest) { (contact, stop) -> Void in
                // TODO: assert US numbers only
                for phoneNumberValue in contact.phoneNumbers {
                    let phoneNumberInfo = phoneNumberValue.value as! CNPhoneNumber
                    if let phoneNumber = PhoneNumber(text: phoneNumberInfo.stringValue) {
                        phoneNumbers.insert(phoneNumber)
                    }
                }
            }
            
            completion(phoneNumbers: phoneNumbers)
        } catch {
            completion(phoneNumbers: nil)
        }
    }
    
    func postUsersFind(listPhoneNumbers: PhoneNumber, completion: (listOfValidUserAccounts: [UserAccount]?)-> () ) {
        let params = [
            "phone": listPhoneNumbers
        ]
        
        let request = ServerRequest(type: .POST, url: Constants.Endpoints.usersFind)
        request.expectedContentType = .JSON
        request.expectedBodyType = .JSONArray
        request.execute(params) { (response) -> Void in
            switch (response) {
            case .Success(let response):
                var listUserAccounts =  [UserAccount]()
                let JSONResponse = response as! [AnyObject]
                
                for object in JSONResponse {
                    guard let account = object as? [String: AnyObject] else {
                        completion(listOfValidUserAccounts: nil)
                        return
                    }
                    guard let firstName = account["first_name"] as? String,
                        lastName = account["last_name"] as? String,
                        phone = account["phone_number"] as? String
                    else {
                        completion(listOfValidUserAccounts: nil)
                        return
                    }
                    let phoneObject = PhoneNumber(text: phone)
                    let accountObject = UserAccount(firstName: firstName, lastName: lastName
                        , phoneNumber: phoneObject!)
                    listUserAccounts.append(accountObject)
                }
                completion(listOfValidUserAccounts: listUserAccounts)
            case .Failure(let failure):
                request.logResponseFailure(failure)
                completion(listOfValidUserAccounts: nil)
            }
        }
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        let hud = MBProgressHUD(view: self.view)
        hud.dimBackground = true
        hud.labelText = Constants.HUDProgressText
        
        self.view.addSubview(hud)
        hud.show(true)
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
        dispatch_async(queue) { () -> Void in
            // TODO replace this with Don's fetch result
            let a1 = UserAccount(firstName: "John", lastName: "Smith", phoneNumber: PhoneNumber(text: "5551112222")!)
            let acc1 = RegisteredUserAccount(userAccount: a1, identifier: 123)
            let a2 = UserAccount(firstName: "Jaden", lastName: "Jones", phoneNumber: PhoneNumber(text: "4449998888")!)
            let acc2 = RegisteredUserAccount(userAccount: a2, identifier: 456)
            let dummy: Set<RegisteredUserAccount> = [acc1, acc2]
            
            self.session = ShareSession(sharerAccount: self.accountManager.registeredAccount!, endCondition: self.endCondition, needsDriver: self.needsDriver, receivers: dummy)
            self.sessionManager.registerSession(self.session, completion: { (success) -> () in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if success {
                        self.presentSessionController()
                    } else {
                        self.presentErrorAlert("Failed to create sharing session")
                    }
                })
            })
        }
    }
    
    private func presentSessionController() {
        let shareSessionController = self.storyboard!.instantiateViewControllerWithIdentifier("PickMeUp") as! ShareSessionViewController
        shareSessionController.accountManager = accountManager
        shareSessionController.locationManager = locationManager
        shareSessionController.sessionManager = sessionManager
        shareSessionController.session = session
        
        self.navigationController!.viewControllers = [shareSessionController]
    }
}
