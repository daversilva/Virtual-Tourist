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
    
    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var photosAlbumCollection: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    override var activityIndicatorTag: Int { get { return ViewTag.photoAlbum.rawValue }}
    
    var coordinate: CLLocationCoordinate2D!
    var photos = [Photo]()
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationMapView.delegate = self
        loadPhotoAlbumLocationInMapView()
        
        photosAlbumCollection.delegate = self
        photosAlbumCollection.dataSource = self
        
        configureFlowLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: Action
    
    @IBAction func newCollection(_ sender: UIButton) {
        startActivityIndicator()
        configureUI(false)
        FlickClient.shared.imagesFromFlickByLatituteAndLongitude { (photos, success, error) in
            if success {
                self.photos = photos
                DispatchQueue.main.async {
                    self.photosAlbumCollection.reloadData()
                    self.configureUI(true)
                }
                self.stopActivityIndicator()
            }
        }
    }

}

// MARK: PhotoAlbumViewController - Extension

extension PhotoAlbumViewController {
    
    // MARK: Methods
    
    func loadPhotoAlbumLocationInMapView() {
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
        newCollectionButton.isEnabled = enable
        newCollectionButton.alpha = enable ? 1.0 : 0.5
    }

}

// MARK: MKMapViewDelegate - Methods

extension PhotoAlbumViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return MapViewHelper.shared.viewForAnnotation(mapView, annotation)
    }
}

// MARK: UICollectionViewDelegate - Methods

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    
}

// MARK: UICollectionViewDataSource - Methods

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoAlbumCollectionView", for: indexPath) as! PhotoAlbumCollectionViewCell
        let photo = photos[(indexPath as NSIndexPath).row]
        cell.photo.image = photo.photo
        return cell
    }
    
}
