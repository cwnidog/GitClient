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
  
  let imageQueue = NSOperationQueue() // don't handle getting images in the main thread
  
  var urlSession : NSURLSession
  
  init () {
    let ephemeralConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
    self.urlSession = NSURLSession(configuration: ephemeralConfig)
    
    // see if we have a stored access token, if so - use it
    if let accessToken = NSUserDefaults.standardUserDefaults().valueForKey(self.accessTokenUserDefaultsKey) as? String {
      self.accessToken = accessToken
    }
  } // init()
  
  // request an access token from the Github API for OAuth
  func requestAccessToken() {
    let url = "https://github.com/login/oauth/authorize?client_id=\(self.clientID)&scope=user,repo"
    UIApplication.sharedApplication().openURL(NSURL(string: url)!) // open the app's local URL in a browser
  } // requestAccessToken()
  
  // handle the request for the OAuth access token and the response
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
            
            // parse the response string using delimeters, want the second part, which contains the access token string itself
            let accessTokenComponent = tokenResponse?.componentsSeparatedByString("&").first as String
            let accessToken = accessTokenComponent.componentsSeparatedByString("=").last
            println (accessToken) // let's see what we got
            
            // set the token property for this time and store it away for reuse later
            self.accessToken = accessToken
            NSUserDefaults.standardUserDefaults().setValue(accessToken!, forKey: self.accessTokenUserDefaultsKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            
          case 400 ... 499:
            println("Got response saying error at our end with status code: \(httpResponse.statusCode)")
            
          case 500 ... 599:
            println("Got response saying error at server end with status code: \(httpResponse.statusCode)")

          default: // unrecognized status code
            println("Hit default case with status code: \(httpResponse.statusCode)")
          } // switch on statusCode
        } // if let httpResponse
      } // got some kind of response back
    }) // completionHandler enclosure
    
    dataTask.resume() // fire the request off
  } // andleCallbackURL()
  
  // get the repositories matching the search term from Github, if any
  func fetchRepositoriesForSearchTerm(searchTerm: String, callback : ([Repository]?, String?) ->(Void)) {
    
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
            
          default: // unrecognized status code
            println("Hit the default case, didn't recognize response status code.")
          } // switch statusCode
        } // if let httpReponse
      } // error == nil
    }) // completionHandler
    
    dataTask.resume() // fire it up
  } // fetchRepositoriesForSearchTerm()
  
  
  // get the users matching the search term from Github, if any
  func fetchUsersForSearchTerm(searchTerm : String, callback : ([User]?, String?) -> (Void)) {
    
    // set up the request
    let url = NSURL(string: "https://api.github.com/search/users?q=\(searchTerm)")
    let request = NSMutableURLRequest(URL: url!)
    request.setValue("token \(self.accessToken!)", forHTTPHeaderField: "Authorization")
    
    let dataTask = self.urlSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
      
      if error == nil {
        if let httpResponse = response as? NSHTTPURLResponse {
          switch httpResponse.statusCode {
          case 200 ... 299 :
            if let jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? [String:AnyObject] {
              if let itemsArray = jsonDictionary["items"] as? [[String:AnyObject]] {
                // build the array of users
                var users = [User]() // an array of user information
                for item in itemsArray {
                  let user = User(jsonDictionary: item)
                  users.append(user)
                } // for item
                
                // go back to the main thread and execute the callback
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                  callback(users, nil)
                })
              } // if let items_array
            } // if let jsonDictionary
            
          case 400 ... 499:
            println("Got response saying error at our end with status code: \(httpResponse.statusCode)")
            
          case 500 ... 599:
            println("Got response saying error at server end with status code: \(httpResponse.statusCode)")
            
          default : // unrecognized status code
            println("Hit default case with status code: \(httpResponse.statusCode)")
          } // switch
        } // if let httpResponse
      } // error = nil
      
      else {
        println(error.localizedDescription) // what was the error?
      }
    }) // callback enclosure
    dataTask.resume()
  } // fetchUsersForSearchTerm
  
  // get the user's avatar image from Github, don't need authorization for this
  func fetchAvatarImageForURL(url : String, completionHandler : (UIImage) -> (Void)) {
    
    let url = NSURL(string : url)
    self.imageQueue.addOperationWithBlock { () -> Void in
      let imageData = NSData(contentsOfURL: url!) // the Github images aren't protected
      let image = UIImage(data: imageData!)
      completionHandler(image!)
    } // completionHandler
    
  } // fetchAvatarImageForURL()

  
} // Network Controller
