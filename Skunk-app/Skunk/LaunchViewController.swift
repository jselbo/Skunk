//
//  LaunchViewController.swift
//  Skunk
//
//  Created by Josh on 9/23/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    var accountManager: UserAccountManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        accountManager = UserAccountManager()
        if let account = accountManager.registeredAccount {
            print("got saved account: \(account)")
        } else {
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TODO remove this later
    private func testSaveAccount() {
        let account = UserAccount(firstName: "Josh", lastName: "Selbo", phoneNumber: "6361237777", password: "abc123")
        let registeredAccount = RegisteredUserAccount(userAccount: account, identifier: 9990)
        
        var success = false
        do {
            try accountManager.saveRegisteredAccount(registeredAccount)
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
            let alert = UIAlertController(title: Constants.alertTitle, message: "Failed to save account information", preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
