//
//  Category.swift
//  Yelp
//
//  Created by Manuel Deschamps on 5/24/16.
//  Copyright © 2016 deschamps. All rights reserved.
//

import Foundation
import EVReflection

class Category: EVObject {

  static var Categories: [String: Category] = {
    var result: [String: Category] = [:]

    if let filePath = NSBundle.mainBundle().pathForResource("categories", ofType: "json"), data = NSData(contentsOfFile: filePath) {
      do {
        let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! [NSDictionary]
        json.forEach{ categoryDict  in
          let category = Category(dictionary: categoryDict)
          if let categoryCode = category.code {
            result[categoryCode] = category
          }
        }
      } catch { }
    }
    return result
  }()

  var code: String?
  var name: String?
}
