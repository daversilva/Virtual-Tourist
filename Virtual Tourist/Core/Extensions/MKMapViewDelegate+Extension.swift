//
//  MapViewHelper.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 14/08/2018.
//  Copyright © 2018 David Rodrigues. All rights reserved.
//

import Foundation
import MapKit

extension MKMapViewDelegate {
    
    // MARK: Configuration the Pin
    
    func configureForAnnotation(_ mapView: MKMapView, _ annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "locationPin"
        var locationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if locationView == nil {
            locationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            locationView!.canShowCallout = false
            locationView?.animatesDrop = true
            locationView?.pinTintColor = .red
        } else {
            locationView!.annotation = annotation
        }
        
        return locationView
    }
}
