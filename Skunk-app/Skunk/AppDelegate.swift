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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            print("launched with notification: \(remoteNotification)")
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
        let data = userInfo["custom_data"]
        
        switch category {
        case Constants.Notifications.sessionStart:
            break
        case Constants.Notifications.sessionEnd:
            break
        case Constants.Notifications.pickupRequest:
            break
        case Constants.Notifications.pickupResponse:
            break
        default:
            print("Warning: Unrecognized remote notification category: '\(category)'")
        }
    }

    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        // TODO replace with actual logic once we start receiving notifications
        print("BIGGER NOTIFICATION HANDLER")
        print("handle action: id \(identifier), userinfo: \(userInfo), responseInfo: \(responseInfo)")
        print("completion handler: \(completionHandler)")
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        print("LITTLE NOTIFICATION HANDLER")
        print("handle action: id \(identifier), userinfo: \(userInfo)")
        print("completion handler: \(completionHandler)")
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

