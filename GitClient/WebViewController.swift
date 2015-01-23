//
//  WebViewController.swift
//  GitClient
//
//  Created by John Leonard on 1/22/15.
//  Copyright (c) 2015 John Leonard. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
  
  let webView = WKWebView()
  var url : String!

    override func viewDidLoad() {
        super.viewDidLoad()
      
      self.webView.frame = self.view.frame // use the same frame as the container view
      self.view.addSubview(self.webView) // add the webView subview
      
      // set upconstraint so that the webView is always in the center of it's container
      // lifted code from Stack Overflow
      self.webView.setTranslatesAutoresizingMaskIntoConstraints(true) // this time, we want it
      
      // make all four webView margins flexible, so they'll adjust to the container
      self.webView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleBottomMargin
      
      // center the webView in the container
      self.webView.center = CGPointMake(self.view.bounds.midX, self.view.bounds.midY)
      
      // fire off the request for the web page and dislay
      let request = NSURLRequest(URL: NSURL(string : self.url)!)
      self.webView.loadRequest(request)
    } // viewDidLoad
  
} // WebViewController
