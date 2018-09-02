//
//  FlickConvenience.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 16/08/2018.
//  Copyright © 2018 David Rodrigues. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    func imagesFromFlickByLatituteAndLongitude(_ pin: Pin? = nil, completionForHandler: @escaping (_ photos: [Photo],_ success: Bool, _ error: String?) -> Void) {
        
        let _ = taskForGetMethod() { (result, error) in
            
            self.isValidPhotosResult(result, error) { (success, photosDictionary, totalPages, error) in
                
                if success {
                    let _ = self.taskForGetMethod(pin, self.getRandomPage(totalPages)) { (result, error) in
                        
                        self.isValidPhotosResult(result, error) { (success, photosDictionary, totalPages, error) in
                            
                            if success {
                                guard let photosDictionary = photosDictionary else {
                                    return
                                }
                                
                                guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                                    return
                                }
                                
                                guard let pin = pin else { return }
                                
                                let photos = self.parseJsonToPhoto(pin, photosArray)
                                completionForHandler(photos, true, nil)
                            } else {
                                completionForHandler([], false, error)
                            }
                        }
                    }
                } else {
                    completionForHandler([], false, error)
                }

            }
        }
    }
    
    private func getRandomPage(_ totalPages: Int) -> Int {
        let pageLimit = min(totalPages, 40)
        return Int(arc4random_uniform(UInt32(pageLimit))) + 1
    }
    
    private func parseJsonToPhoto(_ pin: Pin, _ results: [[String:AnyObject]]) -> [Photo] {
        var photos = [Photo]()
        
        for result in results {
            let photo = Photo(context: DataController.shared.viewContext)
            photo.url = result[Constants.FlickrResponseKeys.MediumURL] as? String ?? ""
            photo.pin = pin
            photos.append(photo)
        }
        
        return photos
    }
    
    private func isValidPhotosResult(_ result: [String:AnyObject]?,_ error: NSError?, completionForHandlerValidPhoto: @escaping (_ success: Bool, _ photosDictionary: [String:AnyObject]?, _ totalPages: Int, _ error: String?) -> Void) {
        
        guard (error == nil) else {
            completionForHandlerValidPhoto(false, nil, 0, error!.localizedDescription)
            return
        }
        
        guard let result = result else {
            completionForHandlerValidPhoto(false, nil, 0, "Error in return Result")
            return
        }
        
        guard let photosDictionary = result[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
            completionForHandlerValidPhoto(false, nil, 0, "Error in get Photo Dictionary")
            return
        }
        
        guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
            completionForHandlerValidPhoto(false, nil, 0, "Error in get total Pages")
            return
        }
        
        completionForHandlerValidPhoto(true, photosDictionary, totalPages, nil)
    }
}
