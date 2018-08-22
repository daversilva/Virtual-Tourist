//
//  PhotoAlbumViewController+Extension.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 21/08/2018.
//  Copyright © 2018 David Rodrigues. All rights reserved.
//

import Foundation
import UIKit
import MapKit

// MARK: PhotoAlbumViewController - Extension

extension PhotoAlbumViewController {
    
    // MARK: Methods
    
    func loadPhotoAlbumLocationInMapView() {
        let span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(1.0/180.0), longitudeDelta: CLLocationDegrees(1.0/180.0))
        let region = MKCoordinateRegion(center: pin.coordinate, span: span)
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.coordinate
        
        locationMapView.setRegion(region, animated: true)
        locationMapView.addAnnotation(annotation)
    }
    
    func configureFlowLayout() {
        let space: CGFloat = 4.0
        let dimension = (view.frame.size.width - (4 * space)) / 3.0
        
        flowLayout.itemSize = CGSize(width: dimension , height: dimension)
        flowLayout.minimumInteritemSpacing = 4
        flowLayout.minimumLineSpacing = 4
        flowLayout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    }
    
    func configureUI(_ enable: Bool) {
        DispatchQueue.main.async {
            self.newCollectionButton.isEnabled = enable
            self.newCollectionButton.alpha = enable ? 1.0 : 0.5
        }
    }
    
    func configureLocationMapView() {
        locationMapView.delegate = self
        loadPhotoAlbumLocationInMapView()
    }
    
    func configurePhotosAlbumCollection() {
        photosAlbumCollection.delegate = self
        photosAlbumCollection.dataSource = self
    }
    
}

// MARK: MKMapViewDelegate - Methods

extension PhotoAlbumViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return configureForAnnotation(mapView, annotation)
    }
}

// MARK: UICollectionViewDelegate - Methods

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    
}

// MARK: UICollectionViewDataSource - Methods

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoAlbumCollectionView", for: indexPath) as! PhotoAlbumCollectionViewCell
        let cellViewModel = viewModel.getCellViewModel(at: indexPath)
        cell.photo.image = cellViewModel.photo
        return cell
    }
    
}
