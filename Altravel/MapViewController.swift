//
//  MapViewController.swift
//  Altravel
//
//  Created by Giuseppe Macri on 3/26/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    var steps: NSArray?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let steps = self.steps {
            var coordinates: Array<TripStep> = []
            
            for step: TripStep in steps as! [TripStep] {
                if step.coordinates != nil {
                    coordinates.append(step)
                }
            }
            
            self.mapView.addAnnotations(coordinates)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? TripStep {
            
            if annotation.coordinates == nil {
                return nil;
            }
            
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    

    
    
}