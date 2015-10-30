//
//  ReceiveFriendsListViewController.swift
//  Skunk
//
//  Created by Anant Goel on 9/23/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import Foundation
import UIKit

class ReceiveFriendsListViewController: UITableViewController {
    let sessionIdentifier = "Session"
    
    var accountManager: UserAccountManager!
    var sessionManager: ShareSessionManager!
    var selectedSharerSession: ShareSession!
    
    var sharerList = [RegisteredUserAccount]()
    
    var refreshTimer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "listRefresh", forControlEvents: .ValueChanged)
        self.refreshControl = refreshControl*/
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.receiverSessionRefreshInterval, target: self, selector: "listRefresh:", userInfo: nil, repeats: true)
        listRefresh(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        refreshTimer.invalidate()
        refreshTimer = nil
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
        cell.detailTextLabel!.font = UIFont.systemFontOfSize(cell.detailTextLabel!.font.pointSize)
        
        var detailText = ""
        if sharerSession.needsDriver {
            if let driverIdentifier = sharerSession.driverIdentifier {
                if driverIdentifier == self.accountManager.registeredAccount!.identifier {
                    detailText += "You are the driver"
                } else {
                    detailText += "Has a driver"
                }
            } else {
                cell.detailTextLabel!.font = UIFont.boldSystemFontOfSize(cell.detailTextLabel!.font.pointSize)
                detailText += "Needs Driver"
            }
            
            detailText += " | "
        }
        
        switch sharerSession.endCondition {
        case .Location(_):
            detailText += "Sharing until Destination"
        case .Time(let endDate):
            let currentDate = NSDate()
            let secondDifference = endDate.timeIntervalSince1970 - currentDate.timeIntervalSince1970
            let hourDifference = secondDifference / 60.0 / 60.0
            
            // Round to nearest 0.5
            let roundedHourDifference = round(2.0 * hourDifference) / 2.0
            
            let hourText = String(format: "%.1f %@",
                roundedHourDifference, (roundedHourDifference == 1.0 ? "hour" : "hours"))
            detailText += "\(hourText) til done sharing"
        }
        cell.detailTextLabel!.text = detailText
        
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
    
    func listRefresh(sender: AnyObject) {
        sessionManager.fetchShareSessions(accountManager.registeredAccount!) { (registeredAccounts) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let registeredAccounts = registeredAccounts {
                    self.sharerList = registeredAccounts
                    self.tableView.reloadData()
                } else {
                    self.presentErrorAlert("Failed to Request All Sessions")
                }
            })
        }
    }
}
