//
//  AlbumCell.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 27/03/19.
//  Copyright © 2019 David Rodrigues. All rights reserved.
//

import UIKit

class AlbumCell: UICollectionViewCell {
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            imageView.alpha = isSelected ? 0.5 : 1.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViewCell()
    }
    
    private func setupViewCell() {
        addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func set(image: UIImage?) {
        imageView.image = image
        
        DispatchQueue.main.async {
            if image == nil {
                self.activity.startAnimating()
            } else {
                self.activity.stopAnimating()
            }
        }
    }
    
}
