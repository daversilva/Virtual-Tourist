//
//  LocationsViewControllerScreen.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 24/03/19.
//  Copyright © 2019 David Rodrigues. All rights reserved.
//

import Foundation
import MapKit

final class LocationsViewControllerScreen: UIView {
    
    lazy var mapKit: MKMapView = {
        let view = MKMapView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var tapLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        view.text = "Tap Pin to Delete"
        view.font = .boldSystemFont(ofSize: 18)
        view.textAlignment = .center
        view.textColor = .white
        view.isHidden = true
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

extension LocationsViewControllerScreen: CodeView {
    
    func buildViewHierachy() {
        addSubview(mapKit)
        addSubview(tapLabel)
    }
    
    func setupConstraints() {
        mapKit.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        mapKit.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        mapKit.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        mapKit.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
      
        tapLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
        tapLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -24).isActive = true
        tapLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        tapLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    func setupAdditionalConfiguration() {

    }
    
}
