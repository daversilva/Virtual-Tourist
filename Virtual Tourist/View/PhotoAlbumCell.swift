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
    
    override var isSelected: Bool {
        didSet {
            photo.alpha = isSelected ? 0.5 : 1.0
        }
    }
}
