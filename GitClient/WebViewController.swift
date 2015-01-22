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
      
      self.webView.frame = self.view.frame
      self.view.addSubview(self.webView)
      
      let request = NSURLRequest(URL: NSURL(string : self.url)!)
      self.webView.loadRequest(request)

        // Do any additional setup after loading the view.
    } // viewDidLoad

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

} // WebViewController
