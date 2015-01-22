//
//  User.swift
//  GitClient
//
//  Created by John Leonard on 1/21/15.
//  Copyright (c) 2015 John Leonard. All rights reserved.
//

import UIKit

struct User {
  let name : String
  let avatarURL : String
  var avatarImage : UIImage? // user might not have a photo
  
  init(jsonDictionary : [String:AnyObject]) {
    self.name = jsonDictionary["login"] as String
    self.avatarURL = jsonDictionary["avatar_url"] as String
  } // init()
} // User
