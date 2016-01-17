//
//  PlaceMarker.swift
//  Feed Me
//
//  Created by Avijeet Sachdev on 1/17/16.
//  Copyright (c) 2016 Avijeet Sachdev. All rights reserved.
//

import UIKit

class PlaceMarker: GMSMarker {
  let place: GooglePlace
  
  init(place: GooglePlace) {
    self.place = place
    super.init()
    
    position = place.coordinate
    icon = UIImage(named: place.placeType+"_pin")
    groundAnchor = CGPoint(x: 0.5, y: 1)
    appearAnimation = kGMSMarkerAnimationPop
  }
}
