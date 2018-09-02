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
import CoreData

// MARK: MKMapViewDelegate - Methods

extension PhotoAlbumViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return configureForAnnotation(mapView, annotation)
    }
}

// MARK: UICollectionViewDelegate - Methods

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectedPhotosAppend(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        viewModel.selectedPhotosRemove(indexPath: indexPath)
    }

}

// MARK: UICollectionViewDataSource - Methods

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoAlbumCollectionView", for: indexPath) as! PhotoAlbumCell

        cell.set(image: nil)
        let photo = viewModel.getPhotoForIndexPath(at: indexPath)
        
        if let image = photo.image {
            cell.set(image: UIImage(data: image))
        }
        
        return cell
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert: insertedIndexPaths.append(newIndexPath!)
                break
            case .delete:
                deletedIndexPaths.append(indexPath!)
                break
            case .update:
                updatedIndexPaths.append(indexPath!)
                break
            case .move:
                print("Invalid change type.")
                break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        photosAlbumCollection.performBatchUpdates({
            for indexPath in self.insertedIndexPaths {
                photosAlbumCollection.insertItems(at: [indexPath])
            }

            for indexPath in self.deletedIndexPaths {
                photosAlbumCollection.deleteItems(at: [indexPath])
            }

            for indexPath in self.updatedIndexPaths {
                photosAlbumCollection.reloadItems(at: [indexPath])
            }
        }, completion: nil)
    }
}
