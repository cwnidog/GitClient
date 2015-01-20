//
//  NetworkViewController.swift
//  GitClient
//
//  Created by John Leonard on 1/19/15.
//  Copyright (c) 2015 John Leonard. All rights reserved.
//

import Foundation

class NetworkController {
  var urlSession : NSURLSession
  
  init () {
    let ephemeralConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
    self.urlSession = NSURLSession(configuration: ephemeralConfig)
  } // init()
  
  func fetchRepositoriesForSearchTerm(searchTerm: String, callback : ([Repository]?, String?) ->(Void)) {
    let url = NSURL(string: "http://127.0.0.1:3000")
    
    let dataTask = self.urlSession.dataTaskWithURL(url!, completionHandler: { (data,
      urlResponse, error) -> Void in
      if error == nil {
        if let httpResponse = urlResponse as? NSHTTPURLResponse {
          switch httpResponse.statusCode {
          case 200 ... 299:
          if let jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? [String : AnyObject] {
            var repositories = [Repository]()
            var itemArray = jsonDictionary["items"] as NSArray
            for item in itemArray {
              if let dictionary = item as? [String : AnyObject]{
                var repository = Repository(jsonDictionary: dictionary)
                repositories.append(repository)
              } // if let
            } // for item
            // put a request for the Search Repository Menu Table View Controller to reload its data
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
              callback(repositories, nil)
            })
            } // if let httpResponse
            
          case 400 ... 499:
          println("Got response saying error at our end.")
            
          case 500 ... 599:
            println("Got response saying error at server end.")
            
          default:
            println("Hit the default case, didn't recognize response status code.")
          } // switch statusCode
        } // if let httpReponse
      } // error == nil
    }) // completionHandler
    
    dataTask.resume() // fire it up
  } // fetchRepositoriesForSearchTerm()

  
} // Network Controller
