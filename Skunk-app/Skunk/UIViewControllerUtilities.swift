//
//  UIViewControllerUtilities.swift
//  Skunk
//
//  Created by Josh on 9/24/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit

import MBProgressHUD

extension UIViewController {
    
    /// Convenience method to present a `UIAlertController` with the given message.
    func presentErrorAlert(message: String) -> UIAlertController {
        let alert = UIAlertController(title: Constants.alertTitle, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        
        self.presentViewController(alert, animated: true, completion: nil)
        return alert
    }
    
    // Shared by LoginViewController and RegisterViewController.
    // Also dismisses the currently shown MBProgressHUD.
    func saveRegisteredAccountAndPresentMainController(account: RegisteredUserAccount, accountManager: UserAccountManager) {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
        dispatch_async(queue) { () -> Void in
            var success = false
            
            do {
                try accountManager.saveRegisteredAccount(account)
                success = true
            } catch UserAccountManagerError.DefaultsSynchronize {
                print("Error synchronizing NSDefaults")
            } catch UserAccountManagerError.KeychainSave(let saveError, let data) {
                print("Error \(saveError) saving data '\(data)' to keychain")
            } catch {
                print("Unknown save error")
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                MBProgressHUD(forView: self.view)?.hide(true)
                
                if success {
                    // Jump to Main storyboard
                    let mainStoryboard = UIStoryboard(name: Constants.Storyboards.main, bundle: nil)
                    let mainController = mainStoryboard.instantiateInitialViewController() as! MainTabBarController
                    mainController.accountManager = accountManager
                    
                    let window = UIApplication.sharedApplication().delegate!.window!!
                    window.rootViewController = mainController
                } else {
                    self.presentErrorAlert("Failed to save account information")
                }
            })
        }
    }

    
}
