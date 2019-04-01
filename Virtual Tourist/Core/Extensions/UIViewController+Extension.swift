//
//  UIViewController+Extesion.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 19/08/2018.
//  Copyright © 2018 David Rodrigues. All rights reserved.
//

import UIKit

enum  ViewTag: Int {
    case travel = 1, photoAlbum
}

extension UIViewController {
    
    @objc dynamic var activityIndicatorTag: Int { return 999999 }
    
    func startActivityIndicator(style: UIActivityIndicatorViewStyle = .white, location: CGPoint? = nil) {
        
        let loc = location ?? self.view.center
        
        DispatchQueue.main.async {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: style)
            
            activityIndicator.tag = self.activityIndicatorTag
            activityIndicator.center = loc
            activityIndicator.color = UIColor(red: 0.0, green: 119.0/255.0, blue: 251.0/255, alpha: 1.0)
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
            
            self.view.addSubview(activityIndicator)
        }
    }
    
    func stopActivityIndicator() {
        DispatchQueue.main.async {
            if let activityIndicator = self.view.subviews.filter({ $0.tag == self.activityIndicatorTag }).first as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }
}
