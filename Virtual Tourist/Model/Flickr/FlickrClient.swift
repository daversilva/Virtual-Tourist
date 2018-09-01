//
//  FlickClient.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 14/08/2018.
//  Copyright © 2018 David Rodrigues. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {
    
    static let shared = FlickrClient()
    
    var session = URLSession.shared
    
    let statusCodeValid: (Int) -> Bool = { $0 >= 200 && $0 <= 299 }
    
    private override init() {
        super.init()
    }
    
    func taskForGetMethod(_ pin: Pin? = nil, _ withPageNumber: Int? = nil, completionHandlerForGet: @escaping (_ result: [String:AnyObject]?,_ error: NSError?) -> Void) {
        
        let request = URLRequest(url: flickrURLFromParameters(methodParametersImageFlick(pin, withPageNumber)))
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard (self.isValidReturn(data, response, error)), let data = data else {
                self.resultError("Error in Request", "completionHandlerForGet", completionHandlerForGet)
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGet)
        }
        
        task.resume()
    }
        
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: [String:AnyObject]?, _ error: NSError?) -> Void) {
        
        var parsedResult: [String:AnyObject]!
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
        } catch {
            resultError("Could not parse the data as JSON: \(data)", "convertDataWithCompletionHandler", completionHandlerForConvertData)
        }
        
        guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
            resultError("Flickr API returned an error. See error code and message in \(parsedResult)", "convertDataWithCompletionHandler", completionHandlerForConvertData)
            return
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    fileprivate func resultError(_ message: String, _ domain: String, _ completionHandlerForConvertData: ([String : AnyObject]?, NSError?) -> Void) {
        let userInfo = [NSLocalizedDescriptionKey: message]
        completionHandlerForConvertData(nil, NSError(domain: domain, code: 0, userInfo: userInfo))
    }
    
    private func isValidReturn(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Bool {
        guard (error == nil) else {
            print(error!.localizedDescription)
            return false
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, self.statusCodeValid(statusCode) else {
            print("Your request returned a status code other than 2xx!")
            return false
        }
        
        guard let _ = data else {
            print("No data was returned by the request")
            return false
        }
        
        return true
    }
    
    private func methodParametersImageFlick(_ pin: Pin?, _ pageNumber: Int? = nil) -> [String: AnyObject] {
        
        var parameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(pin),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
            ] as [String: AnyObject]
        
        guard let pageNumber = pageNumber else {
            return parameters
        }
        
        parameters[Constants.FlickrParameterKeys.Page] = pageNumber as AnyObject?
        parameters[Constants.FlickrParameterKeys.PerPage] = Constants.FlickrParameterValues.PerPage as AnyObject?
        
        return parameters
    }
    
    private func bboxString(_ pin: Pin?) -> String {
        
        guard let pin = pin else {
            return "0,0,0,0"
        }
        
        let minimumLon = max(pin.longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(pin.latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(pin.longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(pin.latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
}
