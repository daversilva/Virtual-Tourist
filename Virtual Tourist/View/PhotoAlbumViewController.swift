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
    
    //var coordinate: CLLocationCoordinate2D!
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
