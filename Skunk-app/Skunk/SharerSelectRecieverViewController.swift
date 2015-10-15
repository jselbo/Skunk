//
//  SharerSelectRecieverViewController.swift
//  Skunk
//
//  Created by Don Phan on 9/23/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit
import Contacts


class SharerSelectRecieverViewController: UITableViewController {
    
    var endCondition: ShareEndCondition!
    var needsDriver: Bool!
    var accountManager: UserAccountManager!
    var locationManager: LocationManager!
    
    let contactStore = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func donePressed(sender: AnyObject) {
        let shareSessionController = self.storyboard!.instantiateViewControllerWithIdentifier("PickMeUp") as! ShareSessionViewController
        shareSessionController.accountManager = accountManager
        shareSessionController.locationManager = locationManager
        
        self.navigationController!.viewControllers = [shareSessionController]
    }
}
