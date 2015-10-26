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
    
    var handledTermination = false
    
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
        
        receiversTableView.editing = true
    }
    
    //MARK: - IBAction
    
    @IBAction func pickupRequestPressed(sender: AnyObject) {
        pickUpButton.enabled = false
        pickUpButton.backgroundColor = UIColor.grayColor()
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinner.startAnimating()
        spinner.center = pickUpButton.center - pickUpButton.frame.origin
        pickUpButton.addSubview(spinner)
        
        session.needsPickup = true
        sessionManager.sessionPickUpRequest(session) { (success) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                spinner.removeFromSuperview()
                
                if success {
                    self.pickUpButton.backgroundColor = UIColor.greenColor()
                    self.pickUpButton.setTitle("Pickup Requested", forState: .Normal)
                } else {
                    self.presentErrorAlert("Failed to request pickup")
                    self.pickUpButton.enabled = true
                    self.pickUpButton.backgroundColor = UIColor.blueColor()
                }
            })
        }
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
        
        let attributedNameText = NSMutableAttributedString(string: receiver.account.userAccount.fullName)
        if session.driverIdentifier == receiver.account.identifier {
            let attributes = [
                NSFontAttributeName: UIFont.boldSystemFontOfSize(14.0),
            ]
            let driverString = NSAttributedString(string: " (DRIVER)", attributes: attributes)
            attributedNameText.appendAttributedString(driverString)
        }
        
        cell.textLabel!.attributedText = attributedNameText
        cell.textLabel!.textColor = UIColor.blackColor()
        cell.detailTextLabel!.textColor = UIColor.blackColor()
        
        switch receiver.stopSharingState {
        case .None:
            cell.detailTextLabel!.text = ""
            
        case .Requested:
            cell.detailTextLabel!.text = "Requested to end sharing"
            
        case .Accepted:
            cell.textLabel!.textColor = UIColor.grayColor()
            cell.detailTextLabel!.textColor = UIColor.grayColor()
            cell.detailTextLabel!.text = "Sharing Ended"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let action = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "End Sharing") { (action, indexPath) -> Void in
            let receiver = self.receivers[indexPath.row]
            let account = receiver.account.userAccount
            
            self.presentDecisionAlert("Are you sure you would like to stop sharing your location with \"\(account.firstName) \(account.lastName)\"? This receiver must approve your request.") { _ in
                self.sessionManager.sessionTermRequest(self.session, receiver: receiver, completion: { (success) in
                    if !success {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            tableView.reloadData()
                            self.presentErrorAlert("Server Faulted")
                        })
                    }
                })
                tableView.reloadData()
            }
        }
        return [action]
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        let receiver = receivers[indexPath.row]
        if receiver.stopSharingState == .None {
            return .Delete
        } else {
            return .None
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Receivers"
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    
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
                    if success {
                        self.handleHeartbeat(location)
                    } else {
                        print("Failed to send heartbeat: \(location)")
                        dispatch_async(dispatch_get_main_queue()) { _ in
                            if self.presentedViewController == nil {
                                self.presentErrorAlert("Failed to send location to server")
                            }
                        }
                    }
                })
            })
            
            // No rollover
            cumulativeTime = 0
        }
        
        lastUpdatedTime = currentTime
    }
    
    //MARK: - Private methods
    
    private func handleHeartbeat(location: CLLocation) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if self.session.terminated && !self.handledTermination {
                self.handledTermination = true
                
                self.locationManager.delegate = nil
                self.locationManager.stopUpdatingLocation()
                self.presentErrorAlert("Your sharing session has ended.", OKHandler: { (action) -> Void in
                    let startSharingController =
                        self.storyboard!.instantiateViewControllerWithIdentifier("beginSharingScreen")
                        as! ShareMainViewController
                    startSharingController.accountManager = self.accountManager
                    startSharingController.locationManager = self.locationManager
                    self.navigationController!.setViewControllers([startSharingController], animated: true)
                })
            }
            
            self.receiversTableView.reloadData()
        })
    }
}