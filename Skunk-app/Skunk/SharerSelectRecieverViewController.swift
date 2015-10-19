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
    
    let accountCellIdentifier = "FriendCell"
    let contactStore = CNContactStore()
    
    var endCondition: ShareEndCondition!
    var needsDriver: Bool!
    var accountManager: UserAccountManager!
    var locationManager: LocationManager!
    var sessionManager: ShareSessionManager!
    var session: ShareSession!
    
    var registeredAccounts: [RegisteredUserAccount]?
    
    @IBOutlet weak var doneButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sessionManager = ShareSessionManager(account: accountManager.registeredAccount!)
        
        doneButtonItem.enabled = false
        
        // Show progress overlay and disable table view
        self.showProgressHUD()
        
        requestAuthContacts { accessGranted in
            if accessGranted {
                self.readContacts({ (phoneNumbers) -> Void in
                    if let phoneNumbers = phoneNumbers {
                        self.postUsersFind(phoneNumbers, completion: { (accounts) -> () in
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                if let accounts = accounts {
                                    self.registeredAccounts = accounts
                                    self.tableView.reloadData()
                                    
                                    self.hideProgressHUD()
                                } else {
                                    self.presentErrorAlert("Failed to match contacts with server.")
                                }
                            })
                        })
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
    private func readContacts(completion: (phoneNumbers: Set<PhoneNumber>?) -> Void) {
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
    
    func postUsersFind(listPhoneNumbers: Set<PhoneNumber>, completion: (accounts: [RegisteredUserAccount]?)-> () ) {
        let params = [
            "phone_number": Array(listPhoneNumbers),
        ]
        
        let request = ServerRequest(type: .POST, url: Constants.Endpoints.usersFindURL)
        request.expectedContentType = .JSON
        request.expectedBodyType = .JSONArray
        request.execute(params) { (response) -> Void in
            switch (response) {
            case .Success(let response):
                var listUserAccounts =  [RegisteredUserAccount]()
                let JSONResponse = response as! [AnyObject]
                
                for object in JSONResponse {
                    guard let account = object as? [String: AnyObject] else {
                        completion(accounts: nil)
                        return
                    }
                    guard let firstName = account["first_name"] as? String,
                        lastName = account["last_name"] as? String,
                        phone = account["phone_number"] as? String,
                        identifier = account["id"] as? Int
                    else {
                        completion(accounts: nil)
                        return
                    }
                    let phoneObject = PhoneNumber(text: phone)
                    let accountObject = UserAccount(firstName: firstName, lastName: lastName
                        , phoneNumber: phoneObject!)
                    let registeredAccount = RegisteredUserAccount(userAccount: accountObject, identifier: Uid(identifier))
                    listUserAccounts.append(registeredAccount)
                }
                completion(accounts: listUserAccounts)
            case .Failure(let failure):
                request.logResponseFailure(failure)
                completion(accounts: nil)
            }
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
    
    private func showProgressHUD() {
        self.tableView.separatorStyle = .None
        self.tableView.userInteractionEnabled = false
        
        let hud = MBProgressHUD(view: self.view)
        hud.labelText = Constants.HUDProgressText
        hud.show(true)
        self.view.addSubview(hud)
    }
    
    private func hideProgressHUD() {
        self.tableView.separatorStyle = .SingleLine
        self.tableView.userInteractionEnabled = true
        
        MBProgressHUD(forView: self.view).removeFromSuperview()
    }
    
    //MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registeredAccounts?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(accountCellIdentifier, forIndexPath: indexPath)
        
        let account = registeredAccounts![indexPath.row].userAccount
        cell.textLabel!.text = "\(account.firstName) \(account.lastName)"
        cell.detailTextLabel!.text = account.phoneNumber.formatForUser()
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.accessoryType = .Checkmark
        
        doneButtonItem.enabled = true
    }
    
    override func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.accessoryType = .None
        
        // tableView.indexPathsForSelectedRows still includes the current indexPath
        // even though it has been deselected. So, we remove it manually to accurately check its count.
        var selectedRows = tableView.indexPathsForSelectedRows
        if let index = selectedRows?.indexOf(indexPath) {
            selectedRows?.removeAtIndex(index)
        }
        if selectedRows?.count == 0 {
            doneButtonItem.enabled = false
        }
    }
    
    //MARK: - IBAction
    
    @IBAction func donePressed(sender: AnyObject) {
        self.showProgressHUD()
        
        let selectedPaths = self.tableView.indexPathsForSelectedRows
        guard selectedPaths?.count > 0 else {
            self.presentErrorAlert("Please choose one or more receivers to share your location with.")
            return
        }
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
        dispatch_async(queue) { () -> Void in
            var selectedReceivers: Set<RegisteredUserAccount> = []
            for path in selectedPaths! {
                let receiver = self.registeredAccounts![path.row]
                selectedReceivers.insert(receiver)
            }
            
            self.session = ShareSession(sharerAccount: self.accountManager.registeredAccount!, endCondition: self.endCondition, needsDriver: self.needsDriver, receivers: selectedReceivers)
            self.sessionManager.registerSession(self.session, completion: { (success) -> () in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.hideProgressHUD()
                    
                    if success {
                        self.presentSessionController()
                    } else {
                        self.presentErrorAlert("Failed to create sharing session")
                    }
                })
            })
        }
    }
}
