//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 12/08/2018.
//  Copyright © 2018 David Rodrigues. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    
    let viewContext = DataController.shared.viewContext
    var fetchedResultController: NSFetchedResultsController<Photo>!
    
    var selectedToDelete: [IndexPath] = [] {
        didSet{
            self.navigationItem.rightBarButtonItem?.isEnabled = selectedToDelete.count != 0
        }
    }
    
    // MARK: Variables
    
    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var photosAlbumCollection: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var noImages: UILabel!
    
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    override var activityIndicatorTag: Int { get { return ViewTag.photoAlbum.rawValue } }
    
    var pin: Pin!
    
    lazy var viewModel: PhotoAlbumViewModel = {
        return PhotoAlbumViewModel()
    }()
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLocationMapView()
        
        configurePhotosAlbumCollection()
        
        configureFlowLayout()
        
        initViewModel()
        
        setupFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        configureRightBarButtonItem()
    }
    
    // MARK: Init ViewModel
    
    func initViewModel() {
        
        viewModel.updateLoadingStatus = { [unowned self] () in
            let isLoading = self.viewModel.isLoading
            isLoading ? self.startActivityIndicator() : self.stopActivityIndicator()
        }
        
        viewModel.updateUiEnableStatus = { [unowned self] () in
            let isEnable = self.viewModel.isEnable
            self.configureUI(isEnable)
        }
        
        viewModel.updatePhotoSelected = { [unowned self] () in
            let isPhotoSelected = self.viewModel.isPhotoSelected
            self.navigationItem.rightBarButtonItem?.isEnabled = isPhotoSelected
        }
        
        viewModel.updateNoImagesLabel = { [unowned self] () in
            let isEnable = self.viewModel.isImagesFound
            DispatchQueue.main.async {
                self.noImages.isHidden = isEnable
            }
        }
        
    }
    
    // MARK: Action
    
    @IBAction func newCollection(_ sender: UIButton) {
        
        viewModel.isDownloadingPhotos(true)
        selectedToDelete = []
        
        let objects = fetchedResultController.fetchedObjects!
        _ = objects.map { viewContext.delete($0) }
        try? viewContext.save()

        FlickrClient.shared.imagesFromFlickByLatituteAndLongitude(pin) { (photos, success, error) in
            if success {
                if photos.count > 0 {
                    
                    self.viewContext.perform {
                        try? self.viewContext.save()
                    }
                    
                } else {
                    self.viewModel.isImagesFound = false
                }
            }
            self.viewModel.isDownloadingPhotos(false)
        }
    }

}

extension PhotoAlbumViewController {
    
    // MARK: Methods
    
    func loadPhotoAlbumLocationInMapView() {
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(1.0/180.0), longitudeDelta: CLLocationDegrees(1.0/180.0))
        let region = MKCoordinateRegion(center: coordinate, span: span)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        locationMapView.setRegion(region, animated: true)
        locationMapView.addAnnotation(annotation)
    }
    
    func configureFlowLayout() {
        let space: CGFloat = 4.0
        let dimension = (view.frame.size.width - (4 * space)) / 3.0
        flowLayout.itemSize = CGSize(width: dimension , height: dimension)
        flowLayout.minimumInteritemSpacing = 4
        flowLayout.minimumLineSpacing = 4
        flowLayout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    }
    
    func configureUI(_ enable: Bool) {
        DispatchQueue.main.async {
            self.newCollectionButton.isEnabled = enable
            self.newCollectionButton.alpha = enable ? 1.0 : 0.5
        }
    }
    
    func configureLocationMapView() {
        locationMapView.delegate = self
        loadPhotoAlbumLocationInMapView()
    }
    
    func configurePhotosAlbumCollection() {
        photosAlbumCollection.delegate = self
        photosAlbumCollection.dataSource = self
        photosAlbumCollection.allowsMultipleSelection = true
    }
    
    private func configureRightBarButtonItem() {
        let buttonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeItems))
        self.navigationItem.rightBarButtonItem = buttonItem
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    @objc func removeItems() {
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
    
}
