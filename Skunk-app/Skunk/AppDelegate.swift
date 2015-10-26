//
//  AppDelegate.swift
//  Skunk
//
//  Created by Josh on 9/15/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var savedNotificationInfo: NSDictionary?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            savedNotificationInfo = remoteNotification
        }
        
        // If no device token saved, request one
        let defaults = NSUserDefaults.standardUserDefaults()
        let deviceToken = defaults.objectForKey(Constants.keyDeviceToken) as? NSData
        if deviceToken == nil {
            let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(notificationSettings)
        }
        
        return true
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(deviceToken, forKey: Constants.keyDeviceToken)
        guard defaults.synchronize() else {
            NSException(name: "NSUserDefaults synchronize", reason: "Failed to synchronize device token", userInfo: nil).raise()
            return
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        let category = userInfo["aps"]!["category"] as! String
        let data = userInfo["custom_data"] as? [String: AnyObject]
        
        NSNotificationCenter.defaultCenter().postNotificationName(category, object: self, userInfo: data)
    }
    
    func fireNotificationFromLaunch() {
        if let savedNotificationInfo = savedNotificationInfo {
            let category = savedNotificationInfo["aps"]!["category"] as! String
            let data = savedNotificationInfo["custom_data"] as? [String: AnyObject]
            
            NSNotificationCenter.defaultCenter().postNotificationName(category, object: self, userInfo: data)
        }
    }

}

