//
//  SharingViewController.swift
//  Skunk
//
//  Created by Don Phan on 9/21/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit
import MapKit

class SharingViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pickUpButton: UIButton!
    @IBOutlet weak var stopSharingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}