//
//  SearchFilters.swift
//  Yelp
//
//  Created by Manuel Deschamps on 5/24/16.
//  Copyright © 2016 deschamps. All rights reserved.
//

import Foundation

enum SearchFiltersType: Int {
  case Deals = 0
  case Distance
  case Sort
  case Category

  static let count: Int = {
    var max: Int = 0
    while let _ = SearchFiltersType(rawValue: max) { max += 1 }
    return max
  }()

  var title: String {
    switch self {
    case .Deals: return ""
    case .Distance: return "Distance"
    case .Sort: return "Sort by"
    case .Category: return "Category"
    }
  }
}

protocol SearchFilter {
  var name: String? { get }
  var title: String? { get }
  var value: String? { get }
  var on: Bool { get }
}

class SearchBinaryFilter: SearchFilter {
  let title: String?
  let name: String?
  var on: Bool

  init(title: String, name: String) {
    self.title = title
    self.name = name
    self.on = false
  }

  var value: String? { return self.on ? "true" : nil }
}

class SearchStringFilter: SearchFilter {
  let title: String?
  var value: String?
  var on: Bool

  init(title: String, value: String?) {
    self.title = title
    self.value = value
    self.on = false
  }

  var name: String? { return self.title }
}

struct SearchOptionFilter: SearchFilter {
  let name: String?
  var options: [SearchStringFilter]?

  init(name: String, options: [SearchStringFilter]) {
    self.name = name
    self.options = options
  }

  var title: String? { return self.name }

  var value: String? {
    return selected?.value ?? nil
  }

  var on: Bool {
    return selected != nil
  }

  var selected: SearchStringFilter? {
    get {
      return options?.filter({ (filter) -> Bool in
        return filter.on
      }).first
    }

    set {
      options?.forEach({ (filter) in
        if filter.title == newValue?.title {
          filter.on = true
        } else {
          filter.on = false
        }
      })
    }
  }
}

struct SearchMultiOptionFilter: SearchFilter {
  let name: String?
  var options: [SearchBinaryFilter]?

  init(name: String, options: [SearchBinaryFilter]) {
    self.name = name
    self.options = options
  }

  var title: String? { return self.name }

  var on: Bool {
    return selected != nil
  }

  var value: String? {
    let selectedOptions = selected?.flatMap({ (filter) -> String? in
      return filter.on ? filter.name : nil
    })
    guard selectedOptions?.count > 0 else {
      return nil
    }
    return selectedOptions?.joinWithSeparator(",")
  }

  var selected: [SearchBinaryFilter]? {
    return options?.filter({ (filter) -> Bool in
      return filter.on
    })
  }
}

struct SearchFilters {

  var filters: [SearchFiltersType: SearchFilter]

  init() {
    filters = [:]
    filters[.Deals] = self.dealFilter()
    filters[.Distance] = self.distanceFilter()
    filters[.Sort] = self.sortFilter()
    filters[.Category] = self.categoriesFilter()
  }

  func dealFilter() -> SearchFilter {
    return SearchBinaryFilter(title: "Offering a Deal", name: "deals_filter")
  }

  func distanceFilter() -> SearchFilter {
    let auto = SearchStringFilter(title: "Auto", value: nil)
    let point3Miles = SearchStringFilter(title: "0.3 miles", value: "483")
    let oneMile = SearchStringFilter(title: "1 mile", value: "1600")
    let fiveMiles = SearchStringFilter(title: "5 mile", value: "8046")
    let twentyMiles = SearchStringFilter(title: "20 mile", value: "32186")

    return SearchOptionFilter(name: "radius_filter", options:[
      auto,
      point3Miles,
      oneMile,
      fiveMiles,
      twentyMiles
    ])
  }

  func sortFilter() -> SearchFilter {
    let bestMatch = SearchStringFilter(title: "Best match", value: nil)
    let distance = SearchStringFilter(title: "Distance", value: "1")
    let highestRated = SearchStringFilter(title: "Highest rated", value: "2")

    return SearchOptionFilter(name: "sort", options:[
      bestMatch,
      distance,
      highestRated
    ])
  }

  func categoriesFilter() -> SearchFilter {
    let categories = Category.Categories.values
      .flatMap({ (category) -> SearchBinaryFilter? in
        if let name = category.name, code = category.code {
          return SearchBinaryFilter(title: String(name), name: String(code))
        }
        return nil
      })
      .sort({ (cat1, cat2) -> Bool in
        return cat1.title < cat2.title
      })

    return SearchMultiOptionFilter(name: "category_filter", options: categories)
  }
}