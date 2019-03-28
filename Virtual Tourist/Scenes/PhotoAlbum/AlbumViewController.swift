//
//  AlbumViewController.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 25/03/19.
//  Copyright © 2019 David Rodrigues. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import CoreData
import MapKit

class AlbumViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let screen = AlbumViewControllerScene()
    var viewModel: AlbumViewModelType?

    let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: nil)
    
    override func loadView() {
        super.loadView()
        self.view = screen
        setupViews()
        bindViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    init(viewModel: AlbumViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

extension AlbumViewController {
    
    private func setupViews() {
        navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.rightBarButtonItem = trashButton
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        screen.mapKit.delegate = self
        screen.collectionView.registerCell(AlbumCell.self)
//        screen.collectionView.registerCellWithNib(AlbumCell.self)
        
        guard let viewModel = viewModel else { fatalError("viewModel shouldn't be nil") }
        loadPhotoAlbumLocationInMapView(viewModel.pinModel.value)
        viewModel.loadPhotosEvent.onNext(())
    }
    
    private func bindViews() {
        guard let viewModel = viewModel else { fatalError("viewModel shouldn't be nil") }

        screen.collectionView.delegate = self
        screen.collectionView.dataSource = nil
        
        let datasource = RxCollectionViewSectionedReloadDataSource<SectionOfPhotos>(
            configureCell: { dataSource, collectionView, indexPath, item in
                let cell = collectionView.dequeueReusableCell(type: AlbumCell.self, indexPath: indexPath)
                let photo = self.viewModel?.getPhoto(with: indexPath)
                cell.set(image: nil)
                DownloadImage.shared.loadImageViewCell(cell: cell, photo: photo!)
                return cell
        })
        
        viewModel.section
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: self.screen.collectionView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
        
        screen.newCollectionBtn.rx.tap
            .bind { _ in viewModel.newCollectionEvent.onNext(()) }
            .disposed(by: disposeBag)
    }
    
    private func loadPhotoAlbumLocationInMapView(_ pin: Pin) {
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(1.0/180.0), longitudeDelta: CLLocationDegrees(1.0/180.0))
        let region = MKCoordinateRegion(center: coordinate, span: span)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        screen.mapKit.setRegion(region, animated: true)
        screen.mapKit.addAnnotation(annotation)
    }

    func configureUI(_ enable: Bool) {
        DispatchQueue.main.async {
            self.screen.newCollectionBtn.isEnabled = enable
            self.screen.newCollectionBtn.alpha = enable ? 1.0 : 0.5
        }
    }
    
}

extension AlbumViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let difference: CGFloat = 24.0
        let dimension = (view.frame.size.width - difference) / 3.0
        return CGSize(width: dimension , height: dimension)
    }

}

extension AlbumViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return configureForAnnotation(mapView, annotation)
    }
}
