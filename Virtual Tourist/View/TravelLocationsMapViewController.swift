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
    
    // MARK: Variables
    @IBOutlet weak var locationsMapView: MKMapView!
    let seguePhotoAlbum = "seguePhotoAlbum"
    //var coordinate: CLLocationCoordinate2D!
    var pin: Pin!
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
}

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
