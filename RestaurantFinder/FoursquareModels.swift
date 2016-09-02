//
//  FoursquareModels.swift
//  RestaurantFinder
//
//  Created by Avijeet Sachdev on 8/31/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import Foundation

struct Coordinate {
    let latitude: Double
    let longitude: Double
}

extension Coordinate: CustomStringConvertible {
    var description: String {
        return "\(latitude), \(longitude)"
    }
}