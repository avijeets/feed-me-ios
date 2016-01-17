//
//  UIViewExtension.swift
//  Feed Me
//
//  Created by Avijeet Sachdev on 1/17/16.
//  Copyright (c) 2016 Avijeet Sachdev. All rights reserved.
//

import UIKit

extension UIView {
  
  func lock() {
    if let _ = viewWithTag(10) {
      //View is already locked
    }
    else {
      let lockView = UIView(frame: bounds)
      lockView.backgroundColor = UIColor(white: 0.0, alpha: 0.75)
      lockView.tag = 10
      lockView.alpha = 0.0
      let activity = UIActivityIndicatorView(activityIndicatorStyle: .White)
      activity.hidesWhenStopped = true
      activity.center = lockView.center
      lockView.addSubview(activity)
      activity.startAnimating()
      addSubview(lockView)
      
      UIView.animateWithDuration(0.2) {
        lockView.alpha = 1.0
      }
    }
  }
  
  func unlock() {
    if let lockView = viewWithTag(10) {
      UIView.animateWithDuration(0.2, animations: {
        lockView.alpha = 0.0
        }) { finished in
          lockView.removeFromSuperview()
      }
    }
  }
  
  func fadeOut(duration: NSTimeInterval) {
    UIView.animateWithDuration(duration) {
      self.alpha = 0.0
    }
  }
  
  func fadeIn(duration: NSTimeInterval) {
    UIView.animateWithDuration(duration) {
      self.alpha = 1.0
    }
  }
  
  class func viewFromNibName(name: String) -> UIView? {
    let views = NSBundle.mainBundle().loadNibNamed(name, owner: nil, options: nil)
    return views.first as? UIView
  }
}
