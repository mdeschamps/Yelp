//
//  ListingTableCell.swift
//  Yelp
//
//  Created by Manuel Deschamps on 5/23/16.
//  Copyright © 2016 deschamps. All rights reserved.
//

import UIKit
import AlamofireImage

class ListingTableCell: UITableViewCell {

  @IBOutlet weak var listImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var starsImageView: UIImageView!
  @IBOutlet weak var reviewsCountLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!

  var business: Business? {
    didSet {
      guard let business = self.business else {
        return
      }

      titleLabel.text = business.name
      addressLabel.text = business.location?.shortDisplayAddress ?? ""

      categoryLabel.text = business.categories?.flatMap({ (category) -> String? in
        return category.name
      }).joinWithSeparator(", ") ?? ""

      listImageView.image = nil
      if let imageUrlStr = business.imageUrl,
        imageUrl = NSURL(string: imageUrlStr)
      {
        listImageView.af_setImageWithURL(imageUrl)
      }

      starsImageView.image = nil
      if let imageUrlStr = business.ratingImgUrlLarge,
        starsImgUrl = NSURL(string: imageUrlStr)
      {
        starsImageView.af_setImageWithURL(starsImgUrl)
      }

      if let distanceInMeters = business.distance {
        distanceLabel.text = String(format: "%.2f mi", 0.000621 * distanceInMeters.doubleValue)
      }
    }
  }
    
}
