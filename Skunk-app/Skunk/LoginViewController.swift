//
//  LoginViewController.swift
//  Skunk
//
//  Created by Josh on 9/23/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit

import MBProgressHUD

class LoginViewController: UITableViewController {
    var accountManager: UserAccountManager!

    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginPressed(sender: AnyObject) {
        guard let credentials = validateCredentialFieldsOrAlert() else {
            return
        }
        
        let hud = MBProgressHUD(view: self.view)
        hud.dimBackground = true
        hud.labelText = Constants.HUDProgressText
        
        self.view.addSubview(hud)
        hud.show(true)
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
        dispatch_async(queue) { () -> Void in
            self.accountManager.logInWithCredentials(credentials.phone, password: credentials.password,
                completion: { (registeredAccount: RegisteredUserAccount?) -> () in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if let registeredAccount = registeredAccount {
                            // Login succeeded
                            self.saveRegisteredAccountAndPresentMainController(registeredAccount,
                                accountManager: self.accountManager)
                        } else {
                            // Registration failed
                            hud.hide(true)
                            
                            self.presentErrorAlert("Server login failed")
                        }
                    })
                }
            )
        }
    }
    
    // Return tuple with credentials if good user input. Otherwise present alert
    private func validateCredentialFieldsOrAlert() -> (phone: PhoneNumber, password: String)? {
        guard let phone = PhoneNumber(text: phoneField.text) else {
            presentErrorAlert("Please enter a valid US phone number")
            return nil
        }
        
        let password = passwordField.text
        guard password?.characters.count > 0 else {
            presentErrorAlert("Please enter a password")
            return nil
        }
        
        return (phone: phone, password: password!)
    }
    
}
