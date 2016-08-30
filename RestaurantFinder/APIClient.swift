//
//  APIClient.swift
//  RestaurantFinder
//
//  Created by Avijeet Sachdev on 5/4/16.
//  Copyright © 2016 Avijeet Sachdev. All rights reserved.
//

import Foundation

public let TRENetworkingErrorDomain = "com.treehouse.Stormy.NetworkingError"

public let MissingHTTPResponseError: Int = 10
public let UnexpectedResponseError: Int = 20

protocol JSONDecodable {
    init?(JSON: [String : AnyObject])
}

protocol Endpoint {
    var baseURL: NSURL { get }
    var path: String { get }
    var request: NSURLRequest { get }
}

typealias JSON = [String: AnyObject]
typealias JSONCompletion = (JSON?, NSHTTPURLResponse?, NSError?) -> Void
typealias JSONTask = NSURLSessionDataTask

enum APIResult<T> {
    case Success(T)
    case Failure(ErrorType)
}

protocol APIClient {
    var configuration: NSURLSessionConfiguration { get }
    var session: NSURLSession { get }
    
    func JSONTaskWithRequest(request: NSURLRequest, completion: JSONCompletion) -> JSONTask
    func fetch<T: JSONDecodable>(request: NSURLRequest, parse: JSON -> T?, completion: APIResult<T> -> Void)
}

extension APIClient {
    func JSONTaskWithRequest(request: NSURLRequest, completion: JSONCompletion) -> JSONTask {
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard let HTTPResponse = response as? NSHTTPURLResponse else {
                let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Missing HTTP Response", comment: "")]
                let error = NSError(domain: TRENetworkingErrorDomain, code: MissingHTTPResponseError, userInfo: userInfo)
                completion(nil, nil, error)
                return
            }
            
            if data == nil {
                if let error = error {
                    completion(nil, HTTPResponse, error)
                }
            } else {
                switch HTTPResponse.statusCode {
                case 200:
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String : AnyObject]
                        completion(json, HTTPResponse, nil)
                    } catch let error as NSError {
                        completion(nil, HTTPResponse, error)
                    }
                default:
                    print("Received HTTP response: \(HTTPResponse.statusCode), which was not handled")
                }
            }
        }
        
        return task
    }
    
    func fetch<T>(request: NSURLRequest, parse: JSON -> T?, completion: APIResult<T> -> Void) {
        let task = JSONTaskWithRequest(request) { json, response, error in
            
            dispatch_async(dispatch_get_main_queue()) {
                guard let json = json else {
                    if let error = error {
                        completion(.Failure(error))
                    } else {
                        // TODO: Implement error handling
                    }
                    return
                }
                
                if let resource = parse(json) {
                    completion(.Success(resource))
                } else {
                    let error = NSError(domain: TRENetworkingErrorDomain, code: UnexpectedResponseError, userInfo: nil)
                    completion(.Failure(error))
                }
            }
        }
        
        task.resume()
    }
}

