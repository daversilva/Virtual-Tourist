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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedToDelete.append(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        for index in 0..<selectedToDelete.count {
            if selectedToDelete.contains(indexPath) {
                selectedToDelete.remove(at: index)
            }
        }
    }

}

// MARK: UICollectionViewDataSource - Methods

extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultController.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoAlbumCollectionView", for: indexPath) as! PhotoAlbumCell
        let photo = fetchedResultController.object(at: indexPath)
        
        cell.set(image: nil)
        DownloadImage.shared.loadImageViewCell(cell: cell, photo: photo)
        
        return cell
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = []
        deletedIndexPaths = []
        updatedIndexPaths = []
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
