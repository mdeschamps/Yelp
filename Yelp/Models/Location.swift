//
//  Location.swift
//  Yelp
//
//  Created by Manuel Deschamps on 5/24/16.
//  Copyright © 2016 deschamps. All rights reserved.
//

import Foundation
import EVReflection

class Location: EVObject {
  var displayAddress: [NSString]?
  var address: [String]?
  var city: String?
  var stateCode: String?
  var postalCode: String?
  var neighborhoods: [String]?

  override func setValue(value: AnyObject!, forUndefinedKey key: String) { }

  var shortDisplayAddress: String? {
    var parts: [String] = []
    if let address = address?.first{
      parts.append(address)
    }
    if let neighborhood = neighborhoods?.first {
      parts.append(neighborhood)
    }

    return parts.joinWithSeparator(", ")
  }
}