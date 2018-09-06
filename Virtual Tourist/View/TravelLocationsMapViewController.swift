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
    @IBOutlet weak var tapPinToDelete: UILabel!
    
    var editingPin: Bool = false
    let seguePhotoAlbum = "seguePhotoAlbum"
    
    lazy var viewModel: TravelLocationsViewModel = {
        return TravelLocationsViewModel()
    }()
    
    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configMapView()
        
        initViewModel()
        
        loadPins()
        
        setupRightBarButtonItem()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.dismissFetchedResult()
    }
    
    // MARK: Init ViewModel
    
    func initViewModel() {
        viewModel.setupFetchedResultsController()
    }

}

// MARK: TravelLocationsMapViewController - Extension

extension TravelLocationsMapViewController {
    
    // MARK: Methods
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tapPinToDelete.isHidden = !editing
        editingPin = editing
    }
    
    func configMapView() {
        locationsMapView.delegate = self
        locationsMapView.addGestureRecognizer(configLongPressGestureRecognizer())
    }
    
    fileprivate func configLongPressGestureRecognizer() -> UILongPressGestureRecognizer {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(pinDroppedOnTheMap(_:)))
        gestureRecognizer.delegate = self
        return gestureRecognizer
    }
    
    @objc func pinDroppedOnTheMap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint: CGPoint = gestureRecognizer.location(in: locationsMapView)
            let coordinate = locationsMapView.convert(touchPoint, toCoordinateFrom: locationsMapView)
            
            addPin(coordinate)
            
            loadAnnotationOnMap(nil, coordinate)
        }
    }
    
    private func loadAnnotationOnMap(_ pin: Pin?, _ locationCoordinate: CLLocationCoordinate2D?) {
        let annotation = MKPointAnnotation()
        var coordinate: CLLocationCoordinate2D?
        
        if let pin = pin {
            coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        } else if let locationCoordinate = locationCoordinate {
            coordinate = locationCoordinate
        }
        
        if let coordinate = coordinate {
            annotation.coordinate = coordinate
            locationsMapView.addAnnotation(annotation)
        }
    }
    
    private func loadPins() {
        let pins = viewModel.getPinsOnCoreData()
        for pin in pins {
            loadAnnotationOnMap(pin, nil)
        }
    }
    
    private func addPin(_ coordinate: CLLocationCoordinate2D) {
        viewModel.addPinOnCoreData(coordinate)
    }
    
    func setupRightBarButtonItem() {
        self.navigationItem.rightBarButtonItem = editButtonItem
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == seguePhotoAlbum {
            let destination = segue.destination as! PhotoAlbumViewController
            let pin = sender as! Pin
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
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        if editingPin {
            viewModel.removePin(view)
            mapView.removeAnnotation(view.annotation!)
        } else {
            let pin = viewModel.getPinWithViewMap(view)
            performSegue(withIdentifier: seguePhotoAlbum, sender: pin)
        }
    }
}

// MARK: UIGestureRecognizerDelegate - Methods

extension TravelLocationsMapViewController: UIGestureRecognizerDelegate {}
