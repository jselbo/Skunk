//
//  SharerSelectRecieverViewController.swift
//  Skunk
//
//  Created by Don Phan on 9/23/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit
import Contacts


class SelectRecieverViewController: UITableViewController, LocationUser {
    
    var locationManager: LocationManager!
    
    let contactStore = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestAuthContacts { accessGranted in
            if accessGranted {
                self.readContacts({ (phoneNumbers) -> Void in
                    if let phoneNumbers = phoneNumbers {
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if var destinationController = segue.destinationViewController as? LocationUser {
            destinationController.locationManager = locationManager
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
    func readContacts(completion: (phoneNumbers: [PhoneNumber]?) -> Void) {
        let keys = [CNContactGivenNameKey, CNContactPhoneNumbersKey]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
        do {
            try contactStore.enumerateContactsWithFetchRequest(fetchRequest) { (contact, stop) -> Void in
                print(contact.givenName)
                print(contact.phoneNumbers)
            }
        } catch {
            completion(phoneNumbers: nil)
        }
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let dest = sb.instantiateViewControllerWithIdentifier( "PickMeUp" )
        self.navigationController!.viewControllers = [dest]
    }
}
