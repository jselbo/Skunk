//
//  LoginViewController.swift
//  Skunk
//
//  Created by Josh on 9/23/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit

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
        print("Login")
    }
    
}
