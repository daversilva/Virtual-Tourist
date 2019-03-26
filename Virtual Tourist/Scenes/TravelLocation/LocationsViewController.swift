//
//  LocationsViewController.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 24/03/19.
//  Copyright © 2019 David Rodrigues. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

class LocationsViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var viewModel: LocationsViewModelType?
    
    let screen = LocationsViewControllerScreen()
    
    override func loadView() {
        self.view = screen
        setupViews()
        bindViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.dismissFetchedResultEvent.onNext(())
    }
    
    init(viewModel: LocationsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

// MARK: - Setups
extension LocationsViewController {
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        viewModel?.isEditing.accept(editing)
    }
    
    private func setupViews() {
        navigationItem.title = "Virtual Tourist"
        navigationItem.rightBarButtonItem = editButtonItem
        
        screen.mapKit.delegate = self
        screen.mapKit.addGestureRecognizer(configLongPressGestureRecognizer())
    }
    
    private func bindViews() {
        guard let viewModel = viewModel else { fatalError("viewModel shouldn't be nil") }
        
        viewModel.setupFetchedResultsEvent.onNext(())
        viewModel.loadPinEvent.onNext(())
        
        viewModel.pins
            .bind { [weak self] pins in
                for pin in pins {
                    self?.loadAnnotationOnMap(pin, nil)
                }
            }.disposed(by: disposeBag)
        
        viewModel.isEditing
            .bind { [weak self] value in
                self?.screen.tapLabel.isHidden = !value
            }.disposed(by: disposeBag)
    }
    
    private func navigationToAlbum(_ pin: Pin) {
        let vm = AlbumViewModel()
        let vc = AlbumViewController(viewModel: vm, pin: pin)
        navigationController?.pushViewController(vc, animated: true)
    }
}

//helpers MapKit
extension LocationsViewController {
    
    fileprivate func configLongPressGestureRecognizer() -> UILongPressGestureRecognizer {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(pinDroppedOnTheMap(_:)))
        gestureRecognizer.delegate = self
        return gestureRecognizer
    }
    
    @objc func pinDroppedOnTheMap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint: CGPoint = gestureRecognizer.location(in: screen.mapKit)
            let coordinate = screen.mapKit.convert(touchPoint, toCoordinateFrom: screen.mapKit)
            
            viewModel?.addPinEvent.onNext(coordinate)
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
            screen.mapKit.addAnnotation(annotation)
        }
    }
}

extension LocationsViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return configureForAnnotation(mapView, annotation)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        viewModel?.isEditing
            .bind { [weak self] isEditing in
                guard let strongSelf = self else { return }
                if isEditing {
                    strongSelf.viewModel?.removePinEvent.onNext(view)
                    mapView.removeAnnotation(view.annotation!)
                } else {
                    guard let pin = strongSelf.viewModel?.pinSelected.value else { return}
                    strongSelf.viewModel?.pinSelectedEvent.onNext(view)
                    strongSelf.navigationToAlbum(pin)
                }
            }.disposed(by: disposeBag)
    }
    
}

extension LocationsViewController: UIGestureRecognizerDelegate {}
