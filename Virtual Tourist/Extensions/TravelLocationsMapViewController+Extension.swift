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

// MARK: TravelLocationsMapViewController - Extension

extension TravelLocationsMapViewController {
    
    // MARK: Methods
    
    func configMapView() {
        locationsMapView.delegate = self
        locationsMapView.addGestureRecognizer(configLongPressGestureRecognizer())
    }
    
    fileprivate func configLongPressGestureRecognizer() -> UILongPressGestureRecognizer {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        gestureRecognizer.delegate = self
        return gestureRecognizer
    }
    
    @objc func handleTapGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint: CGPoint = gestureRecognizer.location(in: locationsMapView)
            let coordinate = locationsMapView.convert(touchPoint, toCoordinateFrom: locationsMapView)
            let annotation = MKPointAnnotation()
            
            pin = Pin(coordinate: coordinate)
            
            annotation.coordinate = coordinate
            locationsMapView.addAnnotation(annotation)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == seguePhotoAlbum {
            let destination = segue.destination as! PhotoAlbumViewController
            destination.pin = pin
        }
    }
}

// MARK: MKMapViewDelegate - Methods

extension TravelLocationsMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return configureForAnnotation(mapView, annotation)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        performSegue(withIdentifier: seguePhotoAlbum, sender: nil)
    }
    
}

// MARK: UIGestureRecognizerDelegate - Methods

extension TravelLocationsMapViewController: UIGestureRecognizerDelegate {}
