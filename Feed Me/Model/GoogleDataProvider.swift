//
//  GoogleDataProvider.swift
//  Feed Me
//
//  Created by Avijeet Sachdev on 1/17/16.
//  Copyright (c) 2016 Avijeet Sachdev. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import SwiftyJSON

class GoogleDataProvider {
  var photoCache = [String:UIImage]()
  var placesTask: NSURLSessionDataTask?
  var session: NSURLSession {
    return NSURLSession.sharedSession()
  }
  
  func fetchPlacesNearCoordinate(coordinate: CLLocationCoordinate2D, radius: Double, types:[String], completion: (([GooglePlace]) -> Void)) -> ()
  {
    var urlString = "http://localhost:10000/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true"
    let typesString = types.count > 0 ? types.joinWithSeparator("|") : "food"
    urlString += "&types=\(typesString)"
    urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    
    if let task = placesTask where task.taskIdentifier > 0 && task.state == .Running {
      task.cancel()
    }

    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    placesTask = session.dataTaskWithURL(NSURL(string: urlString)!) {data, response, error in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      var placesArray = [GooglePlace]()
      if let aData = data {
        let json = JSON(data:aData, options:NSJSONReadingOptions.MutableContainers, error:nil)
        if let results = json["results"].arrayObject as? [[String : AnyObject]] {
          for rawPlace in results {
            let place = GooglePlace(dictionary: rawPlace, acceptedTypes: types)
            placesArray.append(place)
            if let reference = place.photoReference {
              self.fetchPhotoFromReference(reference) { image in
                place.photo = image
              }
            }
          }
        }
      }
      dispatch_async(dispatch_get_main_queue()) {
        completion(placesArray)
      }
    }
    placesTask?.resume()
  }
  
  
  func fetchPhotoFromReference(reference: String, completion: ((UIImage?) -> Void)) -> () {
    if let photo = photoCache[reference] as UIImage? {
      completion(photo)
    } else {
      let urlString = "http://localhost:10000/maps/api/place/photo?maxwidth=200&photoreference=\(reference)"
      UIApplication.sharedApplication().networkActivityIndicatorVisible = true
      session.downloadTaskWithURL(NSURL(string: urlString)!) {url, response, error in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        if let url = url {
          let downloadedPhoto = UIImage(data: NSData(contentsOfURL: url)!)
          self.photoCache[reference] = downloadedPhoto
          dispatch_async(dispatch_get_main_queue()) {
            completion(downloadedPhoto)
          }
        }
        else {
          dispatch_async(dispatch_get_main_queue()) {
            completion(nil)
          }
        }
      }.resume()
    }
  }
}
