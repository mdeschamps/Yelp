//
//  YelpNavigationController.swift
//  Yelp
//
//  Created by Manuel Deschamps on 5/24/16.
//  Copyright © 2016 deschamps. All rights reserved.
//

import UIKit

class YelpNavigationController: UINavigationController {

  static let YelpColor = UIColor(red: 175/100, green: 6/100, blue: 6/100, alpha: 1)

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationBar.barTintColor = YelpNavigationController.YelpColor
    navigationBar.tintColor = UIColor.whiteColor()
  }
}
