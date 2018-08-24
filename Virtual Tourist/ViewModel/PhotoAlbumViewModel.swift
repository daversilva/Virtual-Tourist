//
//  PhotoAlbumViewModel.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 20/08/2018.
//  Copyright © 2018 David Rodrigues. All rights reserved.
//

import Foundation
import UIKit

class PhotoAlbumViewModel {
    
    private var photos: [Photo] = [Photo]()
    
    private var cellViewModels: [PhotoAlbumCellViewModel] = [PhotoAlbumCellViewModel]() {
        didSet {
            self.reloadCollectionViewClosure?()
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
    
    var numberOfCells: Int {
        return cellViewModels.count
    }
    
    var updateLoadingStatus: (()->())?
    var reloadCollectionViewClosure: (()->())?
    var updateUiEnableStatus: (()->())?
    
    func newColletion(_ pin: Pin) {
        isLoading = true
        isEnable = false
        cellViewModels = []
        FlickClient.shared.imagesFromFlickByLatituteAndLongitude(pin) { (photos, success, error) in
            if success {
                //self.cellViewModels = photos
                self.processFetchedPhoto(photos: photos)
            }
            self.isEnable = true
            self.isLoading = false
        }
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> PhotoAlbumCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    private func createCellViewModel(photo: Photo) -> PhotoAlbumCellViewModel {
        return PhotoAlbumCellViewModel(photo: photo.photo)
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

struct PhotoAlbumCellViewModel {
    let photo: UIImage
}
