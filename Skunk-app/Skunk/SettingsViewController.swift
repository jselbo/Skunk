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

    @IBOutlet weak var name: UITableViewCell!
    @IBOutlet weak var logOutCell: UITableViewCell!
    @IBOutlet weak var phoneNumber: UITableViewCell!
    
    var numberPoopyTaps = 0
    
    override func viewDidLoad() {
        let account = accountManager.registeredAccount!
        var nameText = account.userAccount.fullName
        #if DEBUG
            nameText += " (ID: \(account.identifier))"
        #endif
        
        name.detailTextLabel!.text = nameText
        phoneNumber.detailTextLabel!.text = account.userAccount.phoneNumber.formatForUser()
        
        let tap = UITapGestureRecognizer(target: self, action: "poopyTap")
        name.contentView.addGestureRecognizer(tap)
    }
    
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
    
    func poopyTap() {
        numberPoopyTaps++
        if numberPoopyTaps >= 10 {
            spawnPoop()
        }
    }

    func spawnPoop() {
        let poopLabel = UILabel()
        poopLabel.text = "💩"
        poopLabel.font = UIFont.systemFontOfSize(128.0)
        self.view.addSubview(poopLabel)
        
        poopLabel.sizeToFit()
        
        let maxX = UInt32(self.view.frame.size.width - poopLabel.frame.size.width)
        let randomX = Int(arc4random_uniform(maxX))
        poopLabel.frame.origin = CGPointMake(CGFloat(randomX), -poopLabel.frame.size.height)
        
        UIView.animateWithDuration(2.0, delay: 0.0, options: [.CurveEaseIn], animations: { () -> Void in
            let height = self.view.frame.size.height
            poopLabel.frame.origin = CGPointMake(CGFloat(randomX), height)
        }) { (done) -> Void in
            poopLabel.removeFromSuperview()
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
