//
//  PhotoDelegateDataSource.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 04/09/2018.
//  Copyright © 2018 David Rodrigues. All rights reserved.
//

import UIKit
import CoreData

class PhotoAlbumDelegateDataSource: NSObject {
    
    let viewContext = DataController.shared.viewContext
    var fetchedResultController: NSFetchedResultsController<Photo>!
    var pin: Pin!
    var photosAlbumCollection: UICollectionView!
    
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    lazy var viewModel: PhotoAlbumViewModel = {
        return PhotoAlbumViewModel()
    }()
    
    var selectedToDelete: [IndexPath] = [] {
        didSet {
            isPhotoSelected = selectedToDelete.count != 0
        }
    }
    
    var updatePhotoSelected: (()->())?
    var isPhotoSelected: Bool = false {
        didSet {
            self.updatePhotoSelected?()
        }
    }
    
    func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch let error {
            print("The fetch could not be performed: \(error)")
        }
    }
    
    func configurePhotosAlbumCollection() {
        photosAlbumCollection.delegate = self
        photosAlbumCollection.dataSource = self
        photosAlbumCollection.allowsMultipleSelection = true
    }
    
    func removeItems() {
        for indexPath in selectedToDelete {
            if selectedToDelete.contains(indexPath) {
                viewContext.delete(fetchedResultController.object(at: indexPath))
            }
        }
        
        do {
            try viewContext.save()
        } catch let error {
            print("Remove photo on Core Data Failed: \(error)")
        }
        
        selectedToDelete.removeAll()
    }
    
}

extension PhotoAlbumDelegateDataSource: UICollectionViewDelegate {
    
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

extension PhotoAlbumDelegateDataSource: UICollectionViewDataSource {
    
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

extension PhotoAlbumDelegateDataSource: NSFetchedResultsControllerDelegate {
    
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
