//
//  AlbumViewController.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 25/03/19.
//  Copyright © 2019 David Rodrigues. All rights reserved.
//

import UIKit

class AlbumViewController: UIViewController {
    
    let screen = AlbumViewControllerScene()
    
    override func loadView() {
        super.loadView()
        self.view = screen
        setupViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

}

extension AlbumViewController {
    
    private func setupViews() {
        navigationController?.navigationBar.isTranslucent = false
        screen.collectionView.delegate = self
        screen.collectionView.dataSource = self
    }
}

extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath)
        cell.backgroundColor = .cyan
        return cell
    }
}

extension AlbumViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let difference: CGFloat = 24.0
        let dimension = (view.frame.size.width - difference) / 3.0
        return CGSize(width: dimension , height: dimension)
    }

}
