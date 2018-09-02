//
//  DownloadImage.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 26/08/2018.
//  Copyright © 2018 David Rodrigues. All rights reserved.
//

import UIKit
import CoreData

let imageCache = NSCache<NSString, UIImage>()

class DownloadImage {
    
    static let shared = DownloadImage()
    private init() {}
    
    let imageDefault = UIImage(named: "no-photo")
    
    func loadImageViewCellFromUrl(urlString: String) -> UIImage {
        
        var imageLoad: UIImage?
        
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) {
            imageLoad = imageFromCache
        } else {
            
            guard let imageUrl = URL(string: urlString) else {
                return imageDefault!
            }
            
            DispatchQueue.global().async {
                guard let data = try? Data(contentsOf: imageUrl) else {
                    imageLoad = self.imageDefault
                    return
                }
                
                guard let image = UIImage(data: data) else {
                    imageLoad = self.imageDefault
                    return
                }
                
                DispatchQueue.main.async {
                    imageCache.setObject(image, forKey: urlString as NSString)
                    imageLoad = image
                }
            }
        }
        
        guard let image = imageLoad else {
            return imageDefault!
        }
        
        return image
    }
    
    func loadImageViewCell(cell: PhotoAlbumCell, urlString: String, photo: Photo) {
        
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) {
            cell.set(image: imageFromCache)
        } else {
            
            guard let imageUrl = URL(string: urlString) else {
                cell.set(image: imageDefault)
                return
            }

            DispatchQueue.global().async {
                guard let data = try? Data(contentsOf: imageUrl) else {
                    cell.set(image: self.imageDefault) 
                    return
                }
                
                guard let image = UIImage(data: data) else {
                    cell.set(image: self.imageDefault)
                    return
                }
                
                DispatchQueue.main.async {
                    imageCache.setObject(image, forKey: urlString as NSString)
                    cell.set(image: image)
                    
                    if let url = URL(string: photo.url!),let imageData = try? Data(contentsOf: url) {
                        photo.image = imageData
                        try? DataController.shared.viewContext.save()
                    }
                }
            }
        }
    }
    
    func downloadImages(_ photos: [Photo], _ viewContext: NSManagedObjectContext, completionHandler: @escaping() -> Void) {
        
        for photo in photos {
            if let url = URL(string: photo.url!),let imageFromData = try? Data(contentsOf: url) {
                photo.image = imageFromData
                try? viewContext.save()
            }
        }
        
        completionHandler()
    }
    
}
