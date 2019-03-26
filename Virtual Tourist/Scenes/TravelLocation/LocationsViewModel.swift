//
//  LocationsViewModel.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 26/03/19.
//  Copyright © 2019 David Rodrigues. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import MapKit
import CoreData

protocol LocationsViewModelType {
    var isEditing: BehaviorRelay<Bool> { get }
    var addPinEvent: PublishSubject<CLLocationCoordinate2D> { get }
    var removePinEvent: PublishSubject<MKAnnotationView> { get }
    var loadPinEvent: PublishSubject<Void> { get }
    var dismissFetchedResultEvent: PublishSubject<Void> { get }
    var setupFetchedResultsEvent: PublishSubject<Void> { get }
    var pinSelectedEvent: PublishSubject<MKAnnotationView> { get }
    var pinSelected: BehaviorRelay<Pin> { get }
    var pins: BehaviorRelay<[Pin]> { get }
}

class LocationsViewModel: LocationsViewModelType {
    
    private let viewContext = DataController.shared.viewContext
    private var fetchedResultController: NSFetchedResultsController<Pin>!
    
    let disposeBag = DisposeBag()
    
    var isEditing = BehaviorRelay<Bool>(value: false)
    var removePinEvent = PublishSubject<MKAnnotationView>()
    var addPinEvent = PublishSubject<CLLocationCoordinate2D>()
    var loadPinEvent = PublishSubject<Void>()
    var dismissFetchedResultEvent = PublishSubject<Void>()
    var setupFetchedResultsEvent = PublishSubject<Void>()
    var pinSelectedEvent = PublishSubject<MKAnnotationView>()
    var pinSelected = BehaviorRelay<Pin>(value: Pin())
    var pins = BehaviorRelay<[Pin]>(value: [])
    
    init() {
        setupFetchedResultsEvent
            .bind { [weak self] in
                self?.setupFetchedResultsController()
            }.disposed(by: disposeBag)
        
        addPinEvent
            .bind { [weak self] coordinate in self?.addPinOnCoreData(coordinate) }
            .disposed(by: disposeBag)
        
        removePinEvent
            .bind { [weak self] view in self?.removePin(view) }
            .disposed(by: disposeBag)
        
        loadPinEvent
            .bind { [weak self] in
                self?.getPinsOnCoreData()
            }.disposed(by: disposeBag)
        
        dismissFetchedResultEvent
            .bind { [weak self] in
                self?.fetchedResultController = nil
            }.disposed(by: disposeBag)
        
        pinSelectedEvent
            .bind { [weak self] view in
                self?.getPinSelected(view)
            }.disposed(by: disposeBag)
    }
}

extension LocationsViewModel {
    
    func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultController.performFetch()
        } catch let error {
            print("The fetch could not be performed: \(error)")
        }
    }
    
    private func getPinSelected(_ view: MKAnnotationView) {
        let pin = getPinWithViewMap(view)
        pinSelected.accept(pin)
    }
    
    private func getPinWithViewMap(_ view: MKAnnotationView) -> Pin {
        
        guard let coordinate = view.annotation?.coordinate else { fatalError("view is nil") }
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@",
                                   argumentArray: [coordinate.latitude, coordinate.longitude])
        fetchRequest.predicate = predicate
        
        guard let result = try? viewContext.fetch(fetchRequest), let pin = result.first else {
            print("Pin not found!")
            return Pin()
        }
        
        return pin
    }
    
    private func removePin(_ view: MKAnnotationView) {
        
        let pin = getPinWithViewMap(view)
        viewContext.delete(pin)
        
        do {
            try viewContext.save()
        } catch let error {
            print("Pin not remove: \(error)")
        }
    }
    
    private func addPinOnCoreData(_ coordinate: CLLocationCoordinate2D) {
        let pin = Pin(context: viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        
        do {
            try viewContext.save()
        } catch let error {
            print(error)
        }
    }
    
    func getPinsOnCoreData() {
        guard let pins = fetchedResultController.fetchedObjects else { return }
        self.pins.accept(pins)
    }
    
}
