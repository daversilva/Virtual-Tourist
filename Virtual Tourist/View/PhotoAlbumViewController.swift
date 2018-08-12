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
    @IBOutlet weak var newCollectionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func newCollection(_ sender: UIButton) {
    }
    

}
