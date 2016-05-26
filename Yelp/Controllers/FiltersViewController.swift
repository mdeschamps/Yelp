//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Manuel Deschamps on 5/24/16.
//  Copyright © 2016 deschamps. All rights reserved.
//

import UIKit

protocol FiltersViewDelegate: class {
  func cancelSearch()
  func searchWithFilters(filters: SearchFilters)
}

class FiltersViewController: UIViewController {

  @IBOutlet weak var filtersTableView: UITableView!

  weak var delegate: FiltersViewDelegate?

  var searchFilters = SearchFilters()

  private var expandedFilters: [SearchFiltersType: Bool] = [
    SearchFiltersType.Distance: false,
    SearchFiltersType.Sort: false,
    SearchFiltersType.Category: false,
  ]

  override func viewDidLoad() {
    super.viewDidLoad()

    filtersTableView.dataSource = self
    filtersTableView.delegate = self
    filtersTableView.backgroundColor = UIColor.whiteColor()

    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(onCancelTapped))
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .Done, target: self, action: #selector(onSearchTapped))
  }

  @objc private func onCancelTapped(sender: AnyObject?){
    delegate?.cancelSearch()
  }

  @objc private func onSearchTapped(sender: AnyObject?){
    delegate?.searchWithFilters(searchFilters)
  }

  private func filterAtIndexPath(indexPath: NSIndexPath) -> SearchFilter? {
    if let filterType = SearchFiltersType(rawValue: indexPath.section) {
      switch searchFilters.filters[filterType] {

      case let binaryFilter as SearchBinaryFilter: return binaryFilter

      case let optionFilter as SearchOptionFilter:
        if (expandedFilters[filterType] == true) {
          return optionFilter.options?[indexPath.row] ?? nil
        } else {
          return optionFilter.selected ?? optionFilter.options?.first
        }

      case let multiOptionFilter as SearchMultiOptionFilter:
        return multiOptionFilter.options?[indexPath.row] ?? nil

      default: return nil
      }
    }

    return nil
  }

  @objc private func onCategoriesToggleTapped(sender: AnyObject?) {
    guard let categories = searchFilters.filters[.Category] as? SearchMultiOptionFilter,
      options = categories.options
    else {
      return
    }

    let startIndex = rowsPerFilter(.Category)
    let sectionIndex = SearchFiltersType.Category.rawValue

    var indexPaths: [NSIndexPath] = []
    for row in startIndex...(options.count ?? 1) - 1 {
      indexPaths.append(NSIndexPath(forRow: row, inSection: sectionIndex))
    }

    filtersTableView.beginUpdates()
    toggleFilterOptions(filtersTableView, indexPaths: indexPaths)
    filtersTableView.endUpdates()
  }

  private func toggleFilterOptions(tableView: UITableView, indexPaths: [NSIndexPath]) {
    if let section = indexPaths.first?.section,
      filterType = SearchFiltersType(rawValue: section)
    {
      let expanding = expandedFilters[filterType] == false
      expandedFilters[filterType] = expanding

      if expanding {
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Bottom)
      } else {
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Bottom)
      }
    }
  }

  private func rowsPerFilter(filterType: SearchFiltersType) -> Int {
    return filterType == .Category ? 3 : 1
  }
}

extension FiltersViewController: UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return SearchFiltersType.count
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let filterType = SearchFiltersType(rawValue: section) {
      if expandedFilters[filterType] == false {
        return rowsPerFilter(filterType)
      }

      switch searchFilters.filters[filterType] {
      case let optionFilter as SearchOptionFilter:
        return optionFilter.options?.count ?? 0

      case let multiOptionFilter as SearchMultiOptionFilter:
        return multiOptionFilter.options?.count ?? 0

      default: return 1
      }
    }

    return 0
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = FilterViewCell()

    if let filter = filterAtIndexPath(indexPath) {
      cell.filter = filter
      cell.delegate = self
    }
    
    return cell
  }

  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return SearchFiltersType(rawValue: section)?.title
  }

  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    if SearchFiltersType(rawValue: section) == .Category {
      return 44
    }
    return 0
  }

  func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    if SearchFiltersType(rawValue: section) == .Category {
      let expandButton = UIButton(type: .Custom)

      if expandedFilters[.Category] == true {
        expandButton.setTitle("Hide categories", forState: .Normal)
      } else {
        expandButton.setTitle("Show all categories", forState: .Normal)
      }
      expandButton.frame = CGRectMake(0, 0, tableView.frame.size.width, 44)
      expandButton.autoresizingMask = [.FlexibleWidth, .FlexibleLeftMargin, .FlexibleRightMargin]
      expandButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
      expandButton.userInteractionEnabled = true
      expandButton.addTarget(self, action: #selector(onCategoriesToggleTapped), forControlEvents: .TouchUpInside)

      let footerView = UIView(frame:CGRectMake(0,0, tableView.frame.size.width, 44))
      footerView.autoresizingMask = .FlexibleWidth

      footerView.addSubview(expandButton)
      return footerView
    }

    return nil
  }
}

extension FiltersViewController: UITableViewDelegate {

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let filterType = SearchFiltersType(rawValue: indexPath.section),
      var filter = searchFilters.filters[filterType] as? SearchOptionFilter
    {
      let startIndex = rowsPerFilter(filterType)
      let expanded = expandedFilters[filterType] == true

      // Deselect current option and select new one, when animation finishes toggle filter options
      CATransaction.begin()
      CATransaction.setCompletionBlock({ [weak self] in
        var indexPaths: [NSIndexPath] = []
        for row in startIndex...(filter.options?.count ?? 1) - 1 {
          indexPaths.append(NSIndexPath(forRow: row, inSection: indexPath.section))
        }

        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: indexPath.section)], withRowAnimation: .None)
        self?.toggleFilterOptions(tableView, indexPaths: indexPaths)
        tableView.endUpdates()
      })

      if expanded {
        var previouslySelectedIndexPath: [NSIndexPath] = []
        if let previouslySelected = filter.selected,
          previouslySelectedRow = filter.options?.indexOf({ return $0.name == previouslySelected.name })
        {
          previouslySelectedIndexPath.append(NSIndexPath(forRow: previouslySelectedRow, inSection: indexPath.section))
        }

        if let option = filter.options?[indexPath.row] {
          filter.selected = option
        }

        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths(previouslySelectedIndexPath, withRowAnimation: .None)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        tableView.endUpdates()
      }

      CATransaction.commit()
    }
  }
}

extension FiltersViewController: FilterViewCellDelegate {
  
  func onSwitchTapped(cell: FilterViewCell, switchButton: UISwitch) {
    guard let
      indexPath = filtersTableView.indexPathForCell(cell),
      filter = filterAtIndexPath(indexPath)
    else {
      return
    }

    if let binaryFilter = filter as? SearchBinaryFilter {
      binaryFilter.on = switchButton.on
    }
  }
}
