//
//  LocationsViewController.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 24/03/19.
//  Copyright © 2019 David Rodrigues. All rights reserved.
//

import UIKit
import MapKit

class LocationsViewController: UIViewController {
    
    let screen = LocationsViewControllerScreen()
    let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
    
    override func loadView() {
        self.view = screen
        setupViews()
        bindViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

// MARK: - Setups
extension LocationsViewController {
    
    private func setupViews() {
        navigationItem.title = "Virtual Tourist"
        navigationItem.rightBarButtonItem = editButton
        
        screen.mapKit.delegate = self
    }
    
    private func bindViews() {
        screen.tapLabel.isHidden = true
    }
}

extension LocationsViewController: MKMapViewDelegate {
    
}
