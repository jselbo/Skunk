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
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        
        self.presentViewController(alert, animated: true, completion: nil)
        return alert
    }
    
}
