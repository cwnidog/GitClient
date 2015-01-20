//
//  NetworkViewController.swift
//  GitClient
//
//  Created by John Leonard on 1/19/15.
//  Copyright (c) 2015 John Leonard. All rights reserved.
//

import UIKit

class NetworkController {
  
  // create a singleton NetworkController
  class var sharedNetworkController : NetworkController {
    struct Static {
      static let instance : NetworkController = NetworkController()
    }
    return Static.instance
  } // sharedNetworkController
  
  let clientSecret = "4add07f700a99e6f5021adffbc146f8ba661491c"
  let clientID = "b7d4ed36d00a4b36a0ce"
  let accessTokenUserDefaultsKey = "accessToken"
  var accessToken : String?
  
  var urlSession : NSURLSession
  
  init () {
    let ephemeralConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
    self.urlSession = NSURLSession(configuration: ephemeralConfig)
    
    // see if we have a stored access token, if so - use it
    if let accessToken = NSUserDefaults.standardUserDefaults().valueForKey(self.accessTokenUserDefaultsKey) as? String {
      self.accessToken = accessToken
    }
  } // init()
  
  // request an access token from the Github API
  func requestAccessToken() {
    let url = "https://github.com/login/oauth/authorize?client_id=\(self.clientID)&scope=user,repo"
    UIApplication.sharedApplication().openURL(NSURL(string: url)!)
  } // requestAccessToken()
  
  func handleCallbackURL(url: NSURL) {
    let code = url.query
    
    //send a POST back to the server asking for a token - going to put the requuest info in the body of the request
    
    // form the string
    let bodyString = "\(code!)&client_id=\(self.clientID)&client_secret=\(self.clientSecret)"
    // encode it as ASCII
    let bodyData = bodyString.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
    let length = bodyData!.length
    
    // put the POST request together
    let postRequest = NSMutableURLRequest(URL: NSURL(string: "https://github.com/login/oauth/access_token")!)
    postRequest.HTTPMethod = "POST"
    postRequest.setValue("\(length)", forHTTPHeaderField: "Content-Length")
    postRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    postRequest.HTTPBody = bodyData
    
    // how are we gonig to deal with the response?
    let dataTask = self.urlSession.dataTaskWithRequest(postRequest, completionHandler: { (data, response, error) -> Void in
      if error == nil { // got some kind of a response back
        
        // need to downcast the response as an NSHTTPURLResponse to read the status code
        if let httpResponse = response as? NSHTTPURLResponse {
          switch httpResponse.statusCode {
          case 200 ... 299: // success
            let tokenResponse = NSString(data: data, encoding: NSASCIIStringEncoding)
            println(tokenResponse) // let's see what we got
            
            // parse the response string using delimeters
            let accessTokeComponent = tokenResponse?.componentsSeparatedByString("&").first as String
            let accessToken = accessTokeComponent.componentsSeparatedByString("=").last
            println (accessToken) // let's see what we got
            // store the token away for reuse
            NSUserDefaults.standardUserDefaults().setValue(accessToken!, forKey: self.accessTokenUserDefaultsKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            
          case 400 ... 499:
            println("Got response saying error at our end with status code: \(httpResponse.statusCode)")
            
          case 500 ... 599:
            println("Got response saying error at server end with status code: \(httpResponse.statusCode)")


          default:
            println("Hit default case with status code: \(httpResponse.statusCode)")
          } // switch on statusCode
        } // if let httpResponse
      } // got some kind of response back
    }) // completionHandler enclosure
    
    dataTask.resume() // fire the request off
  } // andleCallbackURL()
  
  func fetchRepositoriesForSearchTerm(searchTerm: String, callback : ([Repository]?, String?) ->(Void)) {
    
    //let url = NSURL(string: "http://127.0.0.1:3000") - uses node simulator to get canned response
    let url = NSURL(string: "https://api.github.com/search/repositories?q=\(searchTerm)")
    
    let request = NSMutableURLRequest(URL: url!)
    request.setValue("token \(self.accessToken!)", forHTTPHeaderField: "Authorization")
    
    
    let dataTask = self.urlSession.dataTaskWithURL(url!, completionHandler: { (data,
      urlResponse, error) -> Void in
      if error == nil {
        // cast down the url as a NSHTTPURLResponse, so we can get the response's status code
        if let httpResponse = urlResponse as? NSHTTPURLResponse {
          switch httpResponse.statusCode {
          case 200 ... 299: // good response
            // serialize the raw response data into a JSON dictionary and parse
            if let jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? [String : AnyObject] {
              var repositories = [Repository]() // will hold set of repositories from the JSON dictionary
              var itemArray = jsonDictionary["items"] as NSArray // the root dictionary can hold more than one items dictionary
              for item in itemArray {
                if let dictionary = item as? [String : AnyObject]{
                  var repository = Repository(jsonDictionary: dictionary) // pull out what we want to display
                  repositories.append(repository) // add it to the list
                } // if let dictionary
              } // for item in itemArray
              
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
