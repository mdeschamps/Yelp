//
//  SearchResult.swift
//  Yelp
//
//  Created by Manuel Deschamps on 5/24/16.
//  Copyright © 2016 deschamps. All rights reserved.
//

import Foundation
import EVReflection

class SearchResult: EVObject {
  var total: NSNumber?
  var businesses: [Business]?

  override func setValue(value: AnyObject!, forUndefinedKey key: String) { }
}