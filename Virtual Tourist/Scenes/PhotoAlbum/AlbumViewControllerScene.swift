//
//  AlbumViewControllerScene.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 25/03/19.
//  Copyright © 2019 David Rodrigues. All rights reserved.
//

import UIKit
import MapKit

final class AlbumViewControllerScene: UIView {
    
    var cellId = "cellId"
    
    lazy var mapKit: MKMapView = {
        let view = MKMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var newCollectionBtn: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("New Collection", for: .normal)
        view.setTitleColor(UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0), for: .normal)
        view.backgroundColor = .white
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupCodeView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

extension AlbumViewControllerScene: CodeView {
    
    func buildViewHierachy() {
        addSubview(mapKit)
        addSubview(collectionView)
        addSubview(newCollectionBtn)
    }
    
    func setupConstraints() {
        mapKit.heightAnchor.constraint(equalToConstant: 100).isActive = true
        mapKit.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
        mapKit.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor).isActive = true
        mapKit.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor).isActive = true
        
        collectionView.topAnchor.constraint(equalTo: mapKit.bottomAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor).isActive = true
        
        newCollectionBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        newCollectionBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -44).isActive = true
        newCollectionBtn.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor).isActive = true
        newCollectionBtn.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor).isActive = true
        
        collectionView.bottomAnchor.constraint(equalTo: newCollectionBtn.topAnchor).isActive = true
    }
    
    func setupAdditionalConfiguration() {
        backgroundColor = .white
    }
    
}
