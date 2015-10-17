//
//  SharingViewController.swift
//  Skunk
//
//  Created by Don Phan on 9/21/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit
import MapKit

class ShareSessionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LocationManagerDelegate {
    
    let receiverCellIdentifier = "ReceiverCell"
    
    var session: ShareSession!
    var accountManager: UserAccountManager!
    var sessionManager: ShareSessionManager!
    var locationManager: LocationManager!
    
    var currentLocation: CLLocation?
    var lastUpdatedTime: CFTimeInterval!
    // Counts from 0 to Constants.heartbeatFrequency
    var cumulativeTime: CFTimeInterval!
    
    // Store array separate from session.receivers so we can iterate
    var receivers: [ReceiverInfo]!
    
    @IBOutlet weak var pickUpButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var broadcastImageView: UIImageView!
    @IBOutlet weak var receiversTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        broadcastImageView.image = UIImage.animatedImageNamed("broadcast", duration: 1.0)
        
        locationManager.delegate = self
        
        lastUpdatedTime = CACurrentMediaTime()
        cumulativeTime = 0.0
        locationManager.startUpdatingLocation()
        
        receivers = session.receivers.sort { r1, r2 in
            return r1.account.userAccount.firstName.compare(r2.account.userAccount.firstName) == .OrderedAscending
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        locationManager.stopUpdatingLocation()
    }
    
    //MARK: - IBAction
    
    @IBAction func pickupRequestPressed(sender: AnyObject) {
    }
    
    //MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receivers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(receiverCellIdentifier, forIndexPath: indexPath)
        
        let receiver = receivers[indexPath.row]
        let receiverAccount = receiver.account
        cell.textLabel!.text = "\(receiverAccount.userAccount.firstName) \(receiverAccount.userAccount.lastName)"
        cell.textLabel!.textColor = UIColor.blackColor()
        cell.detailTextLabel!.textColor = UIColor.blackColor()
        
        switch receiver.stopSharingState {
        case .None:
            break
        case .Requested:
            cell.detailTextLabel!.text = ""
        case .Accepted(_):
            cell.textLabel!.textColor = UIColor.grayColor()
            cell.detailTextLabel!.textColor = UIColor.grayColor()
            cell.detailTextLabel!.text = "Sharing Ended"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .Default, title: "Title") { (action, indexPath) -> Void in
            print("did something")
        }
        return [action]
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Insert
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        print("Commit editing style")
        if editingStyle == .Delete {
            // TODO delete
        }
    }
    
    //MARK: - UITableViewDelegate
    
    //MARK: - LocationManagerDelegate
    
    func locationManager(manager: LocationManager, didUpdateLocation location: CLLocation) {
        let currentTime = CACurrentMediaTime()
        let elapsedTime = currentTime - lastUpdatedTime
        cumulativeTime = cumulativeTime + elapsedTime
        
        if cumulativeTime >= Constants.heartbeatFrequency {
            // Time to send an update
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
            dispatch_async(queue, { () -> Void in
                self.sessionManager.sendLocationHeartbeat(self.session, location: location, completion: { success in
                    self.handleHeartbeat(location, success: success)
                })
            })
            
            // No rollover
            cumulativeTime = 0
        }
        
        lastUpdatedTime = currentTime
    }
    
    //MARK: - Private methods
    
    // Called off of main thread and not necessarily when application is active
    private func handleHeartbeat(location: CLLocation, success: Bool) {
        if success {
            
        } else {
            print("Failed to send heartbeat: \(location)")
            dispatch_async(dispatch_get_main_queue()) { _ in
                if self.presentedViewController == nil {
                    self.presentErrorAlert("Failed to send location to server")
                }
            }
        }
    }
    
}