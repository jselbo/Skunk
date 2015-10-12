//
//  SharerSelectRecieverViewController.swift
//  Skunk
//
//  Created by Don Phan on 9/23/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit
import Contacts


class SelectRecieverViewController: UITableViewController {
    
    let contactStore = CNContactStore()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        requestAuthContacts { (accessGranted) -> Void in
            readContact()
        }
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Auth To Use Address Book
    func requestAuthContacts( completionHandler: (accessGranted: Bool) -> Void ) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        switch authorizationStatus {
        case .Authorized:
            print("Authorized")
            completionHandler(accessGranted: true)
        case .Denied, .NotDetermined:
            print("Not sure if Denied or Not Determined")
            contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    //Not Determined Case
                    print("Not Determined")
                    completionHandler(accessGranted: access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.Denied {
                        print("Denied")
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            print ("Allow Access Rejected")
                        })
                    }
                }
            })
        default:
            print("default")
            completionHandler(accessGranted: false)
        }
    }
    
    //read address book
    func readContact() -> Bool {
        print("READ CONTACT METHOD")
        self.requestAuthContacts { (accessGranted) -> Void in
            if accessGranted {
                print("Granted Premissions to play with contacts")
                
                let store = CNContactStore()
                store.requestAccessForEntityType(.Contacts) {(access,accessError) -> Void in
                    let keys = [CNContactGivenNameKey, CNContactPhoneNumbersKey]
                    let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
                    do {
                        try store.enumerateContactsWithFetchRequest(fetchRequest) { (contact, stop) -> Void in
                            print(contact.givenName)
                            print(contact.phoneNumbers)
                        }
                        
                    } catch {
                        print( "Unable to get Contacts." )
                    }
                }
            }
        }
        return true
    }
    

    @IBAction func donePressed(sender: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let dest = sb.instantiateViewControllerWithIdentifier( "PickMeUp" )
        self.navigationController!.viewControllers = [dest]
    }
}
