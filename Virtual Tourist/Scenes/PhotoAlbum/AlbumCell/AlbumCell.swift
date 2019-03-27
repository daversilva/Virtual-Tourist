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
    
    lazy var photo: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            photo.alpha = isSelected ? 0.5 : 1.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViewCell()
    }
    
    private func setupViewCell() {
        addSubview(photo)
        
        photo.topAnchor.constraint(equalTo: topAnchor).isActive = true
        photo.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        photo.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        photo.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        backgroundColor = UIColor.gray
    }
    
    func set(image: UIImage?) {
        photo.image = image
        
        DispatchQueue.main.async {
            if image == nil {
                self.activity.startAnimating()
            } else {
                self.activity.stopAnimating()
            }
        }
    }
    
}
