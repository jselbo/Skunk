//
//  SharerSelectRecieverViewController.swift
//  Skunk
//
//  Created by Don Phan on 9/23/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit

class SelectRecieverViewController: UITableViewController, LocationUser {
    
    var locationManager: LocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            // Do any additional setup after loading the view.
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if var destinationController = segue.destinationViewController as? LocationUser {
            destinationController.locationManager = locationManager
        }
    }

    @IBAction func donePressed(sender: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let dest = sb.instantiateViewControllerWithIdentifier( "PickMeUp" )
        self.navigationController!.viewControllers = [dest]
    }
}
