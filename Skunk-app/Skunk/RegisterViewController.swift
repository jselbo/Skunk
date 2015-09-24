//
//  RegisterViewController.swift
//  Skunk
//
//  Created by Josh on 9/23/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit

class RegisterViewController: UITableViewController {
    var accountManager: UserAccountManager!
    
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func registerPressed(sender: AnyObject) {
        self.presentActivityIndicatorAlert("Loading stuff from server")
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
        dispatch_async(queue) { () -> Void in
            NSThread.sleepForTimeInterval(5)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }

    private func registerAccountWithInput(account: UserAccount) throws {
        /*var success = false
        
        do {
            try registerAccountWithInput()
            success = true
        } catch UserAccountManagerError.DefaultsSynchronize {
            print("Error synchronizing NSDefaults")
        } catch UserAccountManagerError.KeychainSave(let saveError, let data) {
            print("Error \(saveError) saving data '\(data)' to keychain")
        } catch {
            print("Unknown save error")
        }
        
        if success {
            // proceed
        } else {
            presentAlert("Failed to save account information")
        }
        
        let account = UserAccount(firstName: "Josh", lastName: "Selbo", phoneNumber: "6361237777", password: "abc123")
        let registeredAccount = RegisteredUserAccount(userAccount: account, identifier: 9990)
        
        try accountManager.saveRegisteredAccount(registeredAccount)
*/
    }
}
