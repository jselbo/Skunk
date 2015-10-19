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
    var sharerSession: ShareSession!
    
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sharerRegisteredUserAccount = sharerList[indexPath.row]
        let sharerUid = sharerRegisteredUserAccount.identifier
        sharerSession = sessionManager.sharerInformation[sharerUid]
    }
    
    func tableView(friendsTableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = friendsTableView.dequeueReusableCellWithIdentifier("Friends Cell", forIndexPath: indexPath)
        let sharerRegisteredUserAccount = sharerList[indexPath.row]
        let sharerUserAccount = sharerRegisteredUserAccount.userAccount
        let sharerUid = sharerRegisteredUserAccount.identifier
        let sharerSession = sessionManager.sharerInformation[sharerUid]
        let needsDriver = sharerSession?.needsDriver
        cell.textLabel!.text = sharerUserAccount.firstName + " " + sharerUserAccount.lastName
        if((needsDriver) != nil){
            cell.detailTextLabel!.text = "Needs Driver"
        }
        else {
            switch sharerSession!.endCondition {
            case .Location(let location): break
            case .Time(let endDate):
                let currentDate = NSDate()
                let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                let difference = calendar.components([.Hour], fromDate: currentDate, toDate: endDate, options: [])
                cell.detailTextLabel?.text = "\(difference.hour) hours till done sharing"
            }
        }
        return cell
    }
    
    private func presentSessionController() {
        let receiverSessionController = self.storyboard!.instantiateViewControllerWithIdentifier("Friends Cell") as! ReceiveMainViewController
        receiverSessionController.sharerSession = sharerSession
    }
}
