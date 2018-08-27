//
//  PhotoAlbumCell.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 24/08/2018.
//  Copyright © 2018 David Rodrigues. All rights reserved.
//

import UIKit

class PhotoAlbumCell: UICollectionViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
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

    private func setupViewCell() {
        backgroundColor = UIColor.gray
        
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 4
        clipsToBounds = true
        
        configuerActivityIndicator()
        addSubview(activity)
    }
    
    private func configuerActivityIndicator() {
        let position = frame.size.width / 1.65
        activity.center = CGPoint(x: position, y: position)
        activity.hidesWhenStopped = true
    }
}
