//
//  PhotoAlbumViewModel.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 20/08/2018.
//  Copyright © 2018 David Rodrigues. All rights reserved.
//

import Foundation

class PhotoAlbumViewModel {
    
    private var cellViewModels: [Photo] = [Photo]() {
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
                self.cellViewModels = photos
            }
            self.isEnable = true
            self.isLoading = false
        }
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> Photo {
        return cellViewModels[indexPath.row]
    }
}
