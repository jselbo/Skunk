//
//  ReceiveFriendsListViewController.swift
//  Skunk
//
//  Created by Anant Goel on 9/23/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import Foundation
import UIKit

class ReceiveFriendsListViewController: UIViewController {
    
    var accountManager: UserAccountManager!
    var sessionManager: ShareSessionManager!
    
    @IBOutlet weak var friendsTableView: UITableView!
    var sharerList = [RegisteredUserAccount]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sessionManager.sendServerRequestforReceiver { (registeredAccounts) -> () in
            self.sharerList = registeredAccounts!
            self.friendsTableView.reloadData()
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(friendsTableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(friendsTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharerList.count;
    }
    
    func tableView(friendsTableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = friendsTableView.dequeueReusableCellWithIdentifier("Friends Cell", forIndexPath: indexPath)
        let sharerItem = sharerList[indexPath.row].userAccount
        cell.textLabel!.text = sharerItem.firstName + " " + sharerItem.lastName
        return cell
    }
}
