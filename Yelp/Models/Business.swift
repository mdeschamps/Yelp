//
//  Listing.swift
//  Yelp
//
//  Created by Manuel Deschamps on 5/24/16.
//  Copyright © 2016 deschamps. All rights reserved.
//

import Foundation
import EVReflection

class Business: EVObject {
  var id: String?
  var imageUrl: String?
  var name: String?
  var snippetText: String?
  var rating: NSNumber?
  var url: String?
  var mobileUrl: String?
  var ratingImgUrl: String?
  var ratingImgUrlSmall: String?
  var ratingImgUrlLarge: String?
  var reviewCount: NSNumber?
  var location: Location?
  var phone: String?
  var displayPhone: String?
  var categories: [Category]?
  var distance: NSNumber?

  override func setValue(value: AnyObject!, forUndefinedKey key: String) { }

  override func propertyConverters() -> [(String?, ((Any?)->())?, (() -> Any?)? )] {
    return [
      ("categories"
        , {
          self.categories = self.mapCategories($0 as? NSArray)
        }
        , { return self.categories?.map { return [$0.name, $0.code] } } )
    ]
  }

  private func mapCategories(categoriesArray: NSArray?) -> [Category]? {
    guard let categoriesArray = categoriesArray else {
      return nil
    }

    return categoriesArray.flatMap { (categoryArr) -> Category? in
      if let categoryArr = categoryArr as? NSArray {
        if let catName = categoryArr[0] as? String, catId = categoryArr[1] as? String {
          if let category = Category.Categories[catId] {
            return category
          } else {
            let category = Category()
            category.code = catId
            category.name = catName
            return category
          }
        }
      }
      return nil
    }
  }
}
