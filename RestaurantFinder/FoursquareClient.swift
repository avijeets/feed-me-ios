//
//  FoursquareClient.swift
//  RestaurantFinder
//
//  Created by Avijeet Sachdev on 8/31/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import Foundation


enum Foursquare: Endpoint {
    case Venues(VenueEndpoint)
    
    enum VenueEndpoint {
        case Search(clientID: String, clientString: String, coordinate: Coordinate, category: Category, query: String?, searchRadius: Int?, limit: Int?)
        enum Category {
            case Food([FoodCategory]?)
            
            enum FoodCategory: String {
                case Afghan = "503288ae91d4c4b30a586d67" // specific value for category in API
            }
            
            var description: String {
                switch self {
                    case .Food(let categories):
                        if let categories = categories {
                            let commaSeparatedString = categories.reduce("") { categoryString, category in
                                "\(categoryString), \(category.rawValue)"
                            }
                            return commaSeparatedString.substringFromIndex(commaSeparatedString.startIndex)
                        }
                        else {
                            return "4d4b"
                        }
                }
            }
        }
    }
}