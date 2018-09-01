//
//  TravelLocationsMapViewController+Extension.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 21/08/2018.
//  Copyright © 2018 David Rodrigues. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

// MARK: MKMapViewDelegate - Methods

extension TravelLocationsMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return configureForAnnotation(mapView, annotation)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pin = viewModel.getPinWithViewMap(view)
        performSegue(withIdentifier: seguePhotoAlbum, sender: pin)
    }
    
}

// MARK: UIGestureRecognizerDelegate - Methods

extension TravelLocationsMapViewController: UIGestureRecognizerDelegate {}
