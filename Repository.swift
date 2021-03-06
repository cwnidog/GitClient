//
//  Repository.swift
//  GitClient
//
//  Created by John Leonard on 1/19/15.
//  Copyright (c) 2015 John Leonard. All rights reserved.
//

import Foundation

struct Repository {
  let name: String
  let author: String
  let url : String
  
  init(jsonDictionary: [String : AnyObject]) {
    self.name = jsonDictionary["name"] as String
    self.author = "John"
    self.url = jsonDictionary["html_url"] as String
  } // init()
  
} // Repository