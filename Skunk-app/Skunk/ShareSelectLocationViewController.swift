//
//  ShareSelectLocationViewController.swift
//  Skunk
//
//  Created by Josh on 10/13/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit
import MapKit

protocol ShareSelectLocationViewControllerDelegate {
    func shareSelectLocationViewController(
        controller: ShareSelectLocationViewController,
        didSelectLocation coordinate: CLLocationCoordinate2D)
}

class ShareSelectLocationViewController: UIViewController, MKMapViewDelegate {
    
    var delegate: ShareSelectLocationViewControllerDelegate?
    var selectedLocation: CLLocationCoordinate2D?
    var selectedAnnotationView: MKAnnotationView?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.userTrackingMode = .Follow
        
        // Drop pin on long press
        let longPress = UILongPressGestureRecognizer(target: self, action: "mapViewLongPressed:")
        mapView.addGestureRecognizer(longPress)
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        guard let selectedLocation = selectedLocation else {
            self.presentErrorAlert("No location selected!")
            return
        }
        
        delegate?.shareSelectLocationViewController(self, didSelectLocation: selectedLocation)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mapViewLongPressed(gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.state == .Began else {
            return
        }
        
        let touchLocation = gestureRecognizer.locationInView(mapView)
        let mapCoordinate = mapView.convertPoint(touchLocation, toCoordinateFromView: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapCoordinate
        mapView.addAnnotation(annotation)
        
        selectedLocation = mapCoordinate
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let userAnnotation = annotation as? MKUserLocation {
            return mapView.viewForAnnotation(userAnnotation)
        }
        
        // Remove existing pin
        // DEFECT #16: does not remove the old pin for new selection
        //selectedAnnotationView?.removeFromSuperview()
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "PinAnnotation")
        annotationView.animatesDrop = true
        annotationView.canShowCallout = false
        
        selectedAnnotationView = annotationView
        return annotationView
    }
    
}
