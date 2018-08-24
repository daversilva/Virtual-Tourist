//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 12/08/2018.
//  Copyright © 2018 David Rodrigues. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    // MARK: Variables
    
    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var photosAlbumCollection: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: Init ViewModel
    
    func initViewModel() {
        
        viewModel.updateLoadingStatus = { [unowned self] () in
            let isLoading = self.viewModel.isLoading
            if isLoading {
                self.startActivityIndicator()
            } else {
                self.stopActivityIndicator()
            }
        }
        
        viewModel.reloadCollectionViewClosure = { [unowned self] () in
            DispatchQueue.main.async {
                self.photosAlbumCollection.reloadData()
            }
        }
        
        viewModel.updateUiEnableStatus = { [unowned self] () in
            let isEnable = self.viewModel.isEnable
            self.configureUI(isEnable)
        }
    }
    
    // MARK: Action
    
    @IBAction func newCollection(_ sender: UIButton) {
        viewModel.newColletion(pin)
    }

}

extension PhotoAlbumViewController {
    
    // MARK: Methods
    
    func loadPhotoAlbumLocationInMapView() {
        let span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(1.0/180.0), longitudeDelta: CLLocationDegrees(1.0/180.0))
        let region = MKCoordinateRegion(center: pin.coordinate, span: span)
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.coordinate
        
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
    }
}
