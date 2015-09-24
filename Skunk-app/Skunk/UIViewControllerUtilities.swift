//
//  UIViewControllerUtilities.swift
//  Skunk
//
//  Created by Josh on 9/24/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// Convenience method to present a `UIAlertController` with the given message.
    func presentErrorAlert(message: String) -> UIAlertController {
        let alert = UIAlertController(title: Constants.alertTitle, message: message, preferredStyle: .Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        return alert
    }
    
    func presentActivityIndicatorAlert(message: String) -> UIAlertController {
        let alert = UIAlertController(title: Constants.alertTitle, message: message, preferredStyle: .Alert)
        
        let indicatorView = UIActivityIndicatorView(frame: alert.view.bounds)
        indicatorView.tintColor = UIColor.orangeColor()
        indicatorView.activityIndicatorViewStyle = .WhiteLarge
        indicatorView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        indicatorView.userInteractionEnabled = false
        indicatorView.startAnimating()
        
        alert.view.addSubview(indicatorView)
        self.presentViewController(alert, animated: true, completion: nil)
        
        return alert
    }
    
}
