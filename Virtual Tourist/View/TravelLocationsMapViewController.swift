//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 12/08/2018.
//  Copyright © 2018 David Rodrigues. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController {
    
    // MARK: Variables
    @IBOutlet weak var locationsMapView: MKMapView!
    let seguePhotoAlbum = "seguePhotoAlbum"
    var coordinate: CLLocationCoordinate2D!

    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
}
