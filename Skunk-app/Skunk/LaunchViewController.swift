//
//  LaunchViewController.swift
//  Skunk
//
//  Created by Josh on 9/23/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    let loginSegue = "Login"
    let registerSegue = "Register"
    
    @IBOutlet weak var debugLoginButton: UIButton!
    
    var accountManager: UserAccountManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Check if account information already stored. If so - skip login flow and
        // load initial controller directly from Main storyboard.
        accountManager = UserAccountManager()
        if accountManager.registeredAccount != nil {
            let mainStoryboard = UIStoryboard(name: Constants.Storyboards.main, bundle: nil)
            let mainController = mainStoryboard.instantiateInitialViewController() as! MainTabBarController
            mainController.accountManager = accountManager
            
            let window = UIApplication.sharedApplication().delegate!.window!!
            window.rootViewController = mainController
        }
        
        // Only show debug login if running in debug mode
//        #if DEBUG
//            debugLoginButton.hidden = false
//        #endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch (segue.identifier!) {
        case loginSegue:
            let loginController = segue.destinationViewController as! LoginViewController
            loginController.accountManager = accountManager
        case registerSegue:
            let registerController = segue.destinationViewController as! RegisterViewController
            registerController.accountManager = accountManager
        default:
            break
        }
    }
    
    @IBAction func debugLoginPressed(sender: AnyObject) {
        let phone = PhoneNumber(text: "9995551234")!
        let account = UserAccount(firstName: "John", lastName: "Smith", phoneNumber: phone, password: "pass")
        account.debug = true
        let debugAccount = RegisteredUserAccount(userAccount: account, identifier: Constants.debugUserIdentifier)
        saveRegisteredAccountAndPresentMainController(debugAccount, accountManager: accountManager)
    }
}
