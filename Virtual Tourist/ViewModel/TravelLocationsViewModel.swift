//
//  TravelLocationsViewModel.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 01/09/2018.
//  Copyright © 2018 David Rodrigues. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class TravelLocationsViewModel {
    // MARK - Variables
    private let viewContext = DataController.shared.viewContext
    private var fetchedResultController: NSFetchedResultsController<Pin>!
}

extension TravelLocationsViewModel {
    
    // MARK - Methods Core Data
    
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
    
    func dismissFetchedResult() {
        fetchedResultController = nil
    }
    
    func getPinsOnCoreData() -> [Pin] {
        guard let pins = fetchedResultController.fetchedObjects else { return [Pin]() }
        return pins
    }
    
    func addPinOnCoreData(_ coordinate: CLLocationCoordinate2D) {
        let pin = Pin(context: viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        
        do {
            try viewContext.save()
        } catch let error {
            print(error)
        }
    }
    
    func getPinWithViewMap(_ view: MKAnnotationView) -> Pin {
        
        guard let coordinate = view.annotation?.coordinate else { fatalError("view is nil") }
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [coordinate.latitude, coordinate.longitude])
        fetchRequest.predicate = predicate
        
        guard let result = try? viewContext.fetch(fetchRequest), let pin = result.first else {
            print("Pin not found!")
            return Pin()
        }
        
        return pin
    }
}
