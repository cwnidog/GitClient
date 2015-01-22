//
//  Extensions.swift
//  GitClient
//
//  Created by John Leonard on 1/22/15.
//  Copyright (c) 2015 John Leonard. All rights reserved.
//

import Foundation

extension String {
  
  // validate the searchTerm string
  func validate() -> Bool {
    let regex = NSRegularExpression(pattern : "[^0-9a-zA-Z\n\\-]", options : nil, error : nil)
    let elements = countElements(self)
    let range = NSMakeRange(0, elements)
    
    // do we find any characters not in the pattern?
    let matches = regex?.numberOfMatchesInString(self, options : nil, range : range)
    
    // if found a character not in the pattern, fail
    if matches > 0 {
      return false
    } // matches > 0
    
    // no illegal characters, pass
    return true
  } // validate()
} // String
