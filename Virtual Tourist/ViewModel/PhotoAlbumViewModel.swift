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
    
    var updateLoadingStatus: (()->())?
    var reloadCollectionViewClosure: (()->())?
    var updateUiEnableStatus: (()->())?
    var updatePhotoSelected: (()->())?
    var updateNoImagesLabel: (()->())?
    
    // MARK: Methods
    
    func isDownloadingPhotos(_ start: Bool) {
        self.isLoading = start
        self.isEnable = !start
    }
    
}
