//
//  SettingsViewController.swift
//  Skunk
//
//  Created by Josh on 9/28/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    var accountManager: UserAccountManager!

    @IBOutlet weak var logOutCell: UITableViewCell!
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        
        switch cell {
        case logOutCell:
            logOut()
            break
        default:
            break
        }
    }
    
    private func logOut() {
        do {
            try accountManager.clearCredentials()
            
            // If succeed, reset back to Login storyboard.
            let loginStoryboard = UIStoryboard(name: Constants.Storyboards.login, bundle: nil)
            let launchController = loginStoryboard.instantiateInitialViewController()!
            
            let window = UIApplication.sharedApplication().delegate!.window!!
            window.rootViewController = launchController
        } catch UserAccountManagerError.KeychainDelete(let status) {
            self.presentErrorAlert("Failed to log out - keychain delete error status: \(status)")
        } catch {
            self.presentErrorAlert("Failed to log out - unknown error")
        }
    }
    
}
