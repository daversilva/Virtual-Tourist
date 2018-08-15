//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 12/08/2018.
//  Copyright © 2018 David Rodrigues. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController {
    
    let seguePhotoAlbum = "seguePhotoAlbum"
    
    @IBOutlet weak var locationsMapView: MKMapView!
    
    var coordinate: CLLocationCoordinate2D!

    override func viewDidLoad() {
        super.viewDidLoad()

        configMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
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
            coordinate = locationsMapView.convert(touchPoint, toCoordinateFrom: locationsMapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            locationsMapView.addAnnotation(annotation)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == seguePhotoAlbum {
            let destination = segue.destination as! PhotoAlbumViewController
            destination.coordinate = coordinate
        }
    }
}

// MARK: MKMapViewDelegate - Methods

extension TravelLocationsMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return MapViewHelper.shared.viewForAnnotation(mapView, annotation)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        performSegue(withIdentifier: seguePhotoAlbum, sender: nil)
    }

}

// MARK: UIGestureRecognizerDelegate - Methods

extension TravelLocationsMapViewController: UIGestureRecognizerDelegate {}
