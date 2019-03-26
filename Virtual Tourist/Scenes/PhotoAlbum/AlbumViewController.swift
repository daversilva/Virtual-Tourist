//
//  AlbumViewController.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 25/03/19.
//  Copyright © 2019 David Rodrigues. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import CoreData
import MapKit

class AlbumViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let screen = AlbumViewControllerScene()
    var viewModel: AlbumViewModelType?
    var pin: Pin!
    
    let viewContext = DataController.shared.viewContext
    var fetchedResultController: NSFetchedResultsController<Photo>!
    let photoAlbumDDS = PhotoAlbumDelegateDataSource()
    
    let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: nil)
    
    override func loadView() {
        super.loadView()
        self.view = screen
        setupViews()
        bindViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    init(viewModel: AlbumViewModelType, pin: Pin) {
        self.viewModel = viewModel
        self.pin = pin
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

extension AlbumViewController {
    
    private func setupViews() {
        navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.rightBarButtonItem = trashButton
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        screen.collectionView.delegate = self
        screen.collectionView.dataSource = self
        
        screen.mapKit.delegate = self
        loadPhotoAlbumLocationInMapView()
        
        setupPhotoDelegateDataSource()
    }
    
    private func bindViews() {
        guard let viewModel = viewModel else { fatalError("viewModel shouldn't be nil") }
        
        screen.newCollectionBtn.rx.tap
            .bind { [weak self] in
                self?.photoAlbumDDS.removeItems()
            }.disposed(by: disposeBag)
    }
    
    func setupPhotoDelegateDataSource() {
        photoAlbumDDS.photosAlbumCollection = screen.collectionView
        photoAlbumDDS.pin = pin
        photoAlbumDDS.configurePhotosAlbumCollection()
        photoAlbumDDS.setupFetchedResultsController()
        fetchedResultController = photoAlbumDDS.fetchedResultController
    }
    
    func loadPhotoAlbumLocationInMapView() {
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(1.0/180.0), longitudeDelta: CLLocationDegrees(1.0/180.0))
        let region = MKCoordinateRegion(center: coordinate, span: span)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        screen.mapKit.setRegion(region, animated: true)
        screen.mapKit.addAnnotation(annotation)
    }
    
    func loadNewCollection() {
        if fetchedResultController.fetchedObjects?.count ?? 0 == 0 {
            //viewModel.newCollectionFromFlickr(pin, fetchedResultController)
        }
    }
    
    func configureUI(_ enable: Bool) {
        DispatchQueue.main.async {
            self.screen.newCollectionBtn.isEnabled = enable
            self.screen.newCollectionBtn.alpha = enable ? 1.0 : 0.5
        }
    }
    
}

extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath)
        cell.backgroundColor = .cyan
        return cell
    }
}

extension AlbumViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let difference: CGFloat = 24.0
        let dimension = (view.frame.size.width - difference) / 3.0
        return CGSize(width: dimension , height: dimension)
    }

}

extension AlbumViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return configureForAnnotation(mapView, annotation)
    }
}
