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
    
    let viewContext = DataController.shared.viewContext
    
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
    
    var isImagesFound: Bool = true {
        didSet {
            self.updateNoImagesLabel?()
        }
    }
    
    var updateLoadingStatus: (()->())?
    var reloadCollectionViewClosure: (()->())?
    var updateUiEnableStatus: (()->())?
    var updateNoImagesLabel: (()->())?
    
    // MARK: Methods
    
    func isDownloadingPhotos(_ start: Bool) {
        self.isLoading = start
        self.isEnable = !start
    }
    
    func newCollectionFromFlickr(_ pin: Pin, _ fetchedController: NSFetchedResultsController<Photo>) {
        
        isDownloadingPhotos(true)
        
        let objects = fetchedController.fetchedObjects!
        _ = objects.map { viewContext.delete($0) }
        try? viewContext.save()
        
        FlickrClient.shared.imagesFromFlickByLatituteAndLongitude(pin) { (photos, success, error) in
            if success {
                if photos.count > 0 {
                    
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
    
}
