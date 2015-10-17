//
//  ReceiveMainViewController.swift
//  Skunk
//
//  Created by Josh on 9/15/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit
import MapKit

class ReceiveMainViewController: UIViewController {
    
    var accountManager: UserAccountManager!
    var sharerSession: ShareSessionManager!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var canPickUp: UIButton!
    @IBOutlet weak var stopReceivingUpdates: UIButton!
    @IBOutlet weak var optionsViewPanel: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //var sharerInformation = sharerSession.sharerInformation
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
