//
//  PhotoAlbumViewModel.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 20/08/2018.
//  Copyright © 2018 David Rodrigues. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PhotoAlbumViewModel {
    
    // MARK: Variables
    
    private let viewContext = DataController.shared.viewContext
    private var fetchedResultController: NSFetchedResultsController<Photo>!
    
    private var photos: [Photo] = [Photo]()
    
    private var cellViewModels: [PhotoAlbumCellViewModel] = [PhotoAlbumCellViewModel]() {
        didSet {
            self.reloadCollectionViewClosure?()
        }
    }
    
    var selectedPhotos: [Photo] = [Photo]() {
        didSet{
            isPhotoSelected = selectedPhotos.count != 0
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    var isEnable: Bool = true {
        didSet {
            self.updateUiEnableStatus?()
        }
    }
    
    var isPhotoSelected: Bool = false {
        didSet {
            self.updatePhotoSelected?()
        }
    }
    
    var isImagesFound: Bool = true {
        didSet {
            self.updateNoImagesLabel?()
        }
    }
    
    var numberOfCells: Int {
        return cellViewModels.count
    }
    
    var numberOfSections: Int {
        return fetchedResultController.sections?.count ?? 1
    }
    
    var numberOfItemsInSection: Int {
        return fetchedResultController.sections?[0].numberOfObjects ?? 0
    }
    
    var updateLoadingStatus: (()->())?
    var reloadCollectionViewClosure: (()->())?
    var updateUiEnableStatus: (()->())?
    var updatePhotoSelected: (()->())?
    var updateNoImagesLabel: (()->())?
    
    // MARK: Methods
    
    func newColletion(_ pin: Pin) {
        isDownloadingPhotos(true)
        cleanViewModel()
        FlickrClient.shared.imagesFromFlickByLatituteAndLongitude(pin) { (photos, success, error) in
            if success {
                if photos.count > 0 {
                    self.processFetchedPhoto(photos: photos)
                    
                    self.viewContext.perform {
                        try? self.viewContext.save()
                    }
                    
                } else {
                    self.isImagesFound = false
                }
            }
            self.isDownloadingPhotos(false)
        }
    }
    
    func cleanViewModel() {
        cellViewModels = []
        selectedPhotos = []
        
        let objects = fetchedResultController.fetchedObjects!
        _ = objects.map { viewContext.delete($0) }
        try? viewContext.save()
    }
    
    func isDownloadingPhotos(_ start: Bool) {
        self.isLoading = start
        self.isEnable = !start
    }
    
    func selectedPhotosAppend(indexPath: IndexPath) {
        let photo = fetchedResultController.object(at: indexPath)
        selectedPhotos.append(photo)
    }
    
    func selectedPhotosRemove(indexPath: IndexPath) {
        let photo = fetchedResultController.object(at: indexPath)
        
        if let index = selectedPhotos.index(where: { $0 == photo }) {
            selectedPhotos.remove(at: index)
        }
    }
    
    func getPhotoForIndexPath(at indexPath: IndexPath) -> Photo {
        return fetchedResultController.object(at: indexPath)
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> PhotoAlbumCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    func removePhotosSelected() {
        for photo in selectedPhotos {
            let index = fetchedResultController.indexPath(forObject: photo)
            let object = fetchedResultController.object(at: index!)
            viewContext.delete(object)
            try? viewContext.save()
        }
        selectedPhotos.removeAll()
    }
    
    private func createCellViewModel(photo: Photo) -> PhotoAlbumCellViewModel {
        return PhotoAlbumCellViewModel(url: photo.url!)
    }
    
    private func processFetchedPhoto(photos: [Photo]) {
        self.photos = photos
        var vms = [PhotoAlbumCellViewModel]()
        for photo in photos {
            vms.append(createCellViewModel(photo: photo))
        }
        self.cellViewModels = vms
    }
    
}

struct PhotoAlbumCellViewModel: Equatable {
    let url: String
    
    static func == (lhs: PhotoAlbumCellViewModel, rhs: PhotoAlbumCellViewModel) -> Bool {
        return lhs.url == rhs.url
    }
}

extension PhotoAlbumViewModel {
    
    // MARK - Methods Core Data
    
    private func save() {
        do {
            try DataController.shared.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
    }
    
    func setupFetchedResultsController(_ pin: Pin) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = PhotoAlbumViewController()
        
        do {
            try fetchedResultController.performFetch()
        } catch let error {
            print("The fetch could not be performed: \(error)")
        }
        
    }
}
