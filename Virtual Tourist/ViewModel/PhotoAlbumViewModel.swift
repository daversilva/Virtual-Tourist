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
    
    var selectedPhotos: [PhotoAlbumCellViewModel] = [PhotoAlbumCellViewModel]() {
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
    
    var numberOfCells: Int {
        return cellViewModels.count
    }
    
    func cellForItemAt(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoAlbumCollectionView", for: indexPath) as! PhotoAlbumCell
        let cellViewModel = getCellViewModel(at: indexPath)
        
        cell.set(image: nil)
        DownloadImage.shared.loadImageViewCell(cell: cell, urlString: cellViewModel.url)
        
        return cell
    }
    
    var updateLoadingStatus: (()->())?
    var reloadCollectionViewClosure: (()->())?
    var updateUiEnableStatus: (()->())?
    var updatePhotoSelected: (()->())?
    
    func newColletion(_ pin: Pin) {
        isDownloadingPhotos(true)
        cleanViewModel()
        FlickClient.shared.imagesFromFlickByLatituteAndLongitude(pin) { (photos, success, error) in
            if success {
                self.processFetchedPhoto(photos: photos)
            }
            self.isDownloadingPhotos(false)
        }
    }
    
    func cleanViewModel() {
        cellViewModels = []
        selectedPhotos = []
    }
    
    func isDownloadingPhotos(_ start: Bool) {
        self.isLoading = start
        self.isEnable = !start
    }
    
    func selectedPhotosAppend(indexPath: IndexPath) {
        let photo = getCellViewModel(at: indexPath)
        selectedPhotos.append(photo)
    }
    
    func selectedPhotosRemove(indexPath: IndexPath) {
        let photo = getCellViewModel(at: indexPath)
        if let index = selectedPhotos.index(where: { $0 == photo }) {
            selectedPhotos.remove(at: index)
        }
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> PhotoAlbumCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    func removePhotosSelected() {
        for photo in selectedPhotos {
            if let index = cellViewModels.index(of: photo) {
                cellViewModels.remove(at: index)
            }
        }
        
        selectedPhotos.removeAll()
    }
    
    private func createCellViewModel(photo: Photo) -> PhotoAlbumCellViewModel {
        return PhotoAlbumCellViewModel(title: photo.title ,url: photo.url)
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
    let title: String
    let url: String
    
    static func == (lhs: PhotoAlbumCellViewModel, rhs: PhotoAlbumCellViewModel) -> Bool {
        return lhs.url == rhs.url
    }
}
