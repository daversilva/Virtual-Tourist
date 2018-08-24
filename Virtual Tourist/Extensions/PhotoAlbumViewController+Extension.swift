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

// MARK: MKMapViewDelegate - Methods

extension PhotoAlbumViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return configureForAnnotation(mapView, annotation)
    }
}

// MARK: UICollectionViewDelegate - Methods

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // TODO
    }
}

// MARK: UICollectionViewDataSource - Methods

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoAlbumCollectionView", for: indexPath) as! PhotoAlbumCell
        let cellViewModel = viewModel.getCellViewModel(at: indexPath)
        cell.photo.image = cellViewModel.photo
        return cell
    }
    
}
