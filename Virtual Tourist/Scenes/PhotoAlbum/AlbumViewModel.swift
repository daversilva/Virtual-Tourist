//
//  AlbumViewModel.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 26/03/19.
//  Copyright © 2019 David Rodrigues. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift
import RxCocoa
import CoreData
import UIKit

struct SectionOfPhotos {
    var header: String
    var items: [Item]
}

extension SectionOfPhotos: SectionModelType {
    typealias Item = Photo
    
    init(original: SectionOfPhotos, items: [Item]) {
        self = original
        self.items = items
    }
}

protocol AlbumViewModelType {
    var pinModel: BehaviorRelay<Pin> { get }
    var setupPhotoDelegateDataSourceEvent: PublishSubject<UICollectionView> { get }
    var newCollectionEvent: PublishSubject<Void> { get }
    var isDownloadPhotos: PublishSubject<Bool> { get }
    var section: BehaviorRelay<[SectionOfPhotos]> { get }
    var photos: BehaviorRelay<[Photo]> { get }
    var loadPhotosEvent: PublishSubject<Void> { get }
    func getPhoto(with indexPath: IndexPath) -> Photo
    func validateIndexPath(_ indexPath: IndexPath) -> Bool
}

class AlbumViewModel: AlbumViewModelType {
    
    let disposeBag = DisposeBag()
    var pin: Pin!
    
    let viewContext = DataController.shared.viewContext
    var fetchedResultController: NSFetchedResultsController<Photo>!
    let photoAlbumDDS = PhotoAlbumDelegateDataSource()
    
    var pinModel = BehaviorRelay<Pin>(value: Pin())
    var setupPhotoDelegateDataSourceEvent = PublishSubject<UICollectionView>()
    var newCollectionEvent = PublishSubject<Void>()
    var isDownloadPhotos = PublishSubject<Bool>()
    var section = BehaviorRelay<[SectionOfPhotos]>(value: [])
    var photos = BehaviorRelay<[Photo]>(value: [])
    var loadPhotosEvent = PublishSubject<Void>()
    
    init(pin: Pin) {
        self.pin = pin
        self.pinModel.accept(pin)
        
        setupFetchedResultsController()
        
        loadPhotosEvent
            .bind { [weak self] in self?.loadPhotos() }
            .disposed(by: disposeBag)

        photos
            .bind { [weak self] phts in
                self?.section.accept([SectionOfPhotos(header: "", items: phts)])
            }.disposed(by: disposeBag)
        
        newCollectionEvent
            .bind { [weak self] in
                self?.loadNewCollection(true)
            }.disposed(by: disposeBag)
        
    }
    
    func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        //fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch let error {
            print("The fetch could not be performed: \(error)")
        }
    }
    
    private func loadPhotos() {
        guard let photos = fetchedResultController.fetchedObjects else { return }
        
        photos.count > 0
            ? self.photos.accept(photos)
            : loadNewCollection()
    }
    
    func getPhoto(with indexPath: IndexPath) -> Photo {
        return fetchedResultController.object(at: indexPath)
    }
    
    private func loadNewCollection(_ isNewCollection: Bool = false) {
        if isNewCollection {
            newCollectionFromFlickr(pin, fetchedResultController)
        } else if fetchedResultController.fetchedObjects?.count ?? 0 == 0 {
            newCollectionFromFlickr(pin, fetchedResultController)
        }
    }
    
    func validateIndexPath(_ indexPath: IndexPath) -> Bool {
        if let sections = fetchedResultController?.sections,
            indexPath.section < sections.count {
            if indexPath.row < sections[indexPath.section].numberOfObjects {
                return true
            }
        }
        return false
    }
    
    private func newCollectionFromFlickr(_ pin: Pin, _ fetchedController: NSFetchedResultsController<Photo>) {
        isDownloadPhotos.onNext(true)
        
        let objects = fetchedController.fetchedObjects!
        _ = objects.map { viewContext.delete($0) }
        try? viewContext.save()
        
        FlickrClient.shared.imagesFromFlickByLatituteAndLongitude(pin) { (photos, success, error) in
            self.isDownloadPhotos.onNext(false)
            if success {
                if photos.count > 0 {
                    self.viewContext.perform {
                        try? self.viewContext.save()
                        self.photos.accept(photos)
                    }
                } else {
                   // self.isImagesFound = false
                }
            }
        }
    }
    
}
