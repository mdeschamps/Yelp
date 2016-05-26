//
//  FilterViewCell.swift
//  Yelp
//
//  Created by Manuel Deschamps on 5/24/16.
//  Copyright © 2016 deschamps. All rights reserved.
//

import UIKit

protocol FilterViewCellDelegate: class {
  func onSwitchTapped(cell: FilterViewCell, switchButton: UISwitch)
}

class FilterViewCell: UITableViewCell {

  weak var delegate: FilterViewCellDelegate?

  var filter: SearchFilter? {
    didSet {
      guard let filter = self.filter else {
        return
      }
      textLabel?.text = filter.title
      setAccessoryView()
    }
  }

  private func setAccessoryView(){
    guard let filter = self.filter else {
      self.accessoryType = .None
      return
    }

    switch filter {
    case let binaryFilter as SearchBinaryFilter:
      self.selectionStyle = .None
      let switchView = UISwitch()
      switchView.on = binaryFilter.on
      switchView.addTarget(self, action: #selector(onSwitchTapped), forControlEvents: .ValueChanged)
      self.accessoryView = switchView

    case let filter as SearchStringFilter:
      self.accessoryType = filter.on && filter.value != nil ? .Checkmark : .None

    default:
      self.accessoryType = .None
    }
  }

  @objc private func onSwitchTapped(switchButton: UISwitch) {
    delegate?.onSwitchTapped(self, switchButton: switchButton)
  }
}
