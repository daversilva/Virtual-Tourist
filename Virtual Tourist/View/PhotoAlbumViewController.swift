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
    
    // MARK: Variables
    
    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var photosAlbumCollection: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var noImages: UILabel!
    
    let viewContext = DataController.shared.viewContext
    var fetchedResultController: NSFetchedResultsController<Photo>!
    var pin: Pin!
    let photoAlbumDDS = PhotoAlbumDelegateDataSource()
    
    override var activityIndicatorTag: Int { get { return ViewTag.photoAlbum.rawValue } }
    
    lazy var viewModel: PhotoAlbumViewModel = {
        return PhotoAlbumViewModel()
    }()
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLocationMapView()
        
        setupPhotoDelegateDataSource()
        
        configureFlowLayout()
        
        initViewModel()
        
        loadNewCollection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        configureRightBarButtonItem()
    }
    
    func setupPhotoDelegateDataSource() {
        photoAlbumDDS.photosAlbumCollection = photosAlbumCollection
        photoAlbumDDS.pin = pin
        photoAlbumDDS.configurePhotosAlbumCollection()
        photoAlbumDDS.setupFetchedResultsController()
        fetchedResultController = photoAlbumDDS.fetchedResultController
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
        
        viewModel.updateNoImagesLabel = { [unowned self] () in
            let isEnable = self.viewModel.isImagesFound
            DispatchQueue.main.async {
                self.noImages.isHidden = isEnable
            }
        }
        
        photoAlbumDDS.updatePhotoSelected = { [unowned self] () in
            let isPhotoSelected = self.photoAlbumDDS.isPhotoSelected
            self.navigationItem.rightBarButtonItem?.isEnabled = isPhotoSelected
        }
        
    }
    
    // MARK: Action
    
    @IBAction func newCollection(_ sender: UIButton) {
        viewModel.newCollectionFromFlickr(pin, fetchedResultController)
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
    
    func loadNewCollection() {
        if fetchedResultController.fetchedObjects?.count ?? 0 == 0 {
            viewModel.newCollectionFromFlickr(pin, fetchedResultController)
        }
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

    private func configureRightBarButtonItem() {
        let buttonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeItems))
        self.navigationItem.rightBarButtonItem = buttonItem
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    @objc func removeItems() {
        photoAlbumDDS.removeItems()
    }
}

extension PhotoAlbumViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return configureForAnnotation(mapView, annotation)
    }
}
