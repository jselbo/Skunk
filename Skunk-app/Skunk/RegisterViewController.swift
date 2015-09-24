//
//  RegisterViewController.swift
//  Skunk
//
//  Created by Josh on 9/23/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit

import MBProgressHUD

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
        guard let account = validateUserAccountFieldsOrAlert() else {
            return
        }
        
        let hud = MBProgressHUD(view: self.view)
        hud.dimBackground = true
        hud.labelText = Constants.HUDProgressText
        
        self.view.addSubview(hud)
        hud.show(true)
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
        dispatch_async(queue) { () -> Void in
            self.accountManager.registerAccount(account,
                completion: { (registeredAccount: RegisteredUserAccount?) -> () in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if let registeredAccount = registeredAccount {
                            // Registration succeeded
                            self.saveRegisteredAccount(registeredAccount)
                        } else {
                            // Registration failed
                            hud.hide(true)
                            
                            self.presentErrorAlert("Server registration failed")
                        }
                    })
                }
            )
        }
    }
    
    /// Validate and return UserAccount, otherwise present alert indicating error.
    private func validateUserAccountFieldsOrAlert() -> UserAccount? {
        let firstName = firstNameField.text
        guard firstName?.characters.count > 0 else {
            presentErrorAlert("Please enter a first name")
            return nil
        }
        
        let lastName = lastNameField.text
        guard lastName?.characters.count > 0 else {
            presentErrorAlert("Please enter a last name")
            return nil
        }
        
        guard let phone = PhoneNumber(text: phoneField.text) else {
            presentErrorAlert("Please enter a valid US phone number")
            return nil
        }
        
        let password = passwordField.text
        guard password?.characters.count > 0 else {
            presentErrorAlert("Please enter a password")
            return nil
        }
        
        // Safe to force unwrap optionals at this point
        return UserAccount(firstName: firstName!, lastName: lastName!, phoneNumber: phone, password: password!)
    }
    
    private func saveRegisteredAccount(account: RegisteredUserAccount) {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
        dispatch_async(queue) { () -> Void in
            var success = false
            
            do {
                try self.accountManager.saveRegisteredAccount(account)
                success = true
            } catch UserAccountManagerError.DefaultsSynchronize {
                print("Error synchronizing NSDefaults")
            } catch UserAccountManagerError.KeychainSave(let saveError, let data) {
                print("Error \(saveError) saving data '\(data)' to keychain")
            } catch {
                print("Unknown save error")
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                MBProgressHUD(forView: self.view).hide(true)
                
                if success {
                    // Jump to Main storyboard
                    let mainStoryboard = UIStoryboard(name: Constants.Storyboards.main, bundle: nil)
                    let mainController = mainStoryboard.instantiateInitialViewController() as! MainTabBarController
                    mainController.accountManager = self.accountManager
                    
                    let window = UIApplication.sharedApplication().delegate!.window!!
                    window.rootViewController = mainController
                } else {
                    self.presentErrorAlert("Failed to save registration information")
                }
            })
        }
    }
}
