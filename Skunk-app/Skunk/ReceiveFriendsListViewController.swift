//
//  ReceiveFriendsListViewController.swift
//  Skunk
//
//  Created by Anant Goel on 9/23/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import Foundation
import UIKit

import QuartzCore

class ReceiveFriendsListViewController: UITableViewController {
    let sessionIdentifier = "Session"
    
    var accountManager: UserAccountManager!
    var sessionManager: ShareSessionManager!
    var selectedSharerSession: ShareSession!
    
    var sharerList = [RegisteredUserAccount]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.darkGrayColor()
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: "listRefresh", forControlEvents: .ValueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.refreshControl!.beginRefreshing()
        
        // Per http://stackoverflow.com/a/22471166
        let offset = CGPointMake(0, self.tableView.contentOffset.y - 80.0)
        self.tableView.setContentOffset(offset, animated: true)
        
        listRefresh()
    }
    
    func reloadData() {
        self.tableView.reloadData()
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        let refreshTitle = "Last updated at \(formatter.stringFromDate(NSDate()))"
        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
        ]
        let attributedText = NSAttributedString(string: refreshTitle, attributes: attributes)
        self.refreshControl!.attributedTitle = attributedText
        
        self.refreshControl!.endRefreshing()
        
        if self.sharerList.isEmpty {
            let noSessionsLabel = UILabel()
            noSessionsLabel.text = "No sessions shared with you\n\nPull to refresh"
            noSessionsLabel.numberOfLines = 0
            noSessionsLabel.textAlignment = .Center
            noSessionsLabel.textColor = UIColor.grayColor()
            
            self.tableView.backgroundView = noSessionsLabel
            self.tableView.separatorStyle = .None
        } else {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .SingleLine
        }
    }
    
    override func numberOfSectionsInTableView(friendsTableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(friendsTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharerList.count;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sharerRegisteredUserAccount = sharerList[indexPath.row]
        let sharerUid = sharerRegisteredUserAccount.identifier
        selectedSharerSession = sessionManager.sharerInformation[sharerUid]
        
        performSegueWithIdentifier(sessionIdentifier, sender: self)
    }
    
    override func tableView(friendsTableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = friendsTableView.dequeueReusableCellWithIdentifier("FriendsCell", forIndexPath: indexPath)
        let sharerRegisteredUserAccount = sharerList[indexPath.row]
        let sharerUserAccount = sharerRegisteredUserAccount.userAccount
        let sharerUid = sharerRegisteredUserAccount.identifier
        let sharerSession = sessionManager.sharerInformation[sharerUid]!
        cell.textLabel!.text = sharerUserAccount.firstName + " " + sharerUserAccount.lastName
        
        if sharerSession.needsDriver {
            cell.detailTextLabel!.text = "Needs Driver"
        } else {
            switch sharerSession.endCondition {
            case .Location(_): break
            case .Time(let endDate):
                let currentDate = NSDate()
                let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                let difference = calendar.components([.Hour], fromDate: currentDate, toDate: endDate, options: [])
                cell.detailTextLabel?.text = "\(difference.hour) hours till done sharing"
            }
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case sessionIdentifier?:
            let sessionController = segue.destinationViewController as! ReceiveMainViewController
            sessionController.accountManager = accountManager
            sessionController.sessionManager = sessionManager
            sessionController.sharerSession = selectedSharerSession
        default:
            break
        }
    }
    
    func listRefresh() {
        sessionManager.fetchShareSessions(accountManager.registeredAccount!) { (registeredAccounts) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let registeredAccounts = registeredAccounts {
                    self.sharerList = registeredAccounts
                    self.reloadData()
                } else {
                    self.presentErrorAlert("Failed to Request All Sessions")
                }
                
                self.refreshControl!.endRefreshing()
            })
        }
    }
}
