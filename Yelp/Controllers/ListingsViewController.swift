//
//  ListingsViewController.swift
//  Yelp
//
//  Created by Manuel Deschamps on 5/23/16.
//  Copyright © 2016 deschamps. All rights reserved.
//

import UIKit
import SwiftLoader

class ListingsViewController: UIViewController {

  @IBOutlet weak var errorMessageLabel: UILabel!
  @IBOutlet weak var listingsTableView: UITableView!

  var searchFilters: SearchFilters?
  let searchBar = UISearchBar()

  var searching: Bool = false
  var isSearching: Bool {
    set {
      objc_sync_enter(self)
      searching = newValue
      objc_sync_exit(self)
    }
    get {
      objc_sync_enter(self)
      let retVal = searching
      objc_sync_exit(self)
      return retVal
    }
  }

  var result: SearchResult? {
    didSet {
      listingsTableView.reloadData()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    var config: SwiftLoader.Config = SwiftLoader.Config()
    config.size = 150
    config.spinnerColor = YelpNavigationController.YelpColor
    config.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0)
    SwiftLoader.setConfig(config)

    listingsTableView.delegate = self
    listingsTableView.dataSource = self
    listingsTableView.registerNib(UINib(nibName: "ListingTableCell", bundle: nil), forCellReuseIdentifier: "listingTableCell")
    listingsTableView.estimatedRowHeight = 100
    listingsTableView.rowHeight = UITableViewAutomaticDimension

    searchBar.delegate = self
    
    navigationItem.titleView = searchBar
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .Plain, target: self, action: #selector(onFilterTapped))

    search()
  }

  @objc private func onFilterTapped(sender: AnyObject?){
    let filtersVC = FiltersViewController()
    filtersVC.delegate = self
    if let filters = searchFilters {
      filtersVC.searchFilters = filters
    }

    let navController = YelpNavigationController(rootViewController: filtersVC)
    presentViewController(navController, animated: true, completion: nil)
  }

  private func search(startIndex startIndex: Int = 0){
    if isSearching {
      return
    }
    isSearching = true
    
    if startIndex == 0 {
      result = nil
      SwiftLoader.show(animated: true)
      listingsTableView.hidden = true
    }

    searchBar.resignFirstResponder()

    hideErrorMessage()
    insertLoadingFooterView()

    YelpAPIClient().search(startIndex: startIndex,term: searchBar.text, filters: searchFilters) { [weak self] (results) in
      guard let weakSelf = self else { return }

      SwiftLoader.hide()
      weakSelf.removeLoadingFooterView()
      weakSelf.isSearching = false

      switch results {
      case .Success(let result):
        weakSelf.listingsTableView.hidden = false

        // if there are results, append new ones and replace them in results
        if var businesses = weakSelf.result?.businesses,
          let newBusinesses = result.businesses {
          businesses.appendContentsOf(newBusinesses)
          result.businesses = businesses
        }
        weakSelf.result = result

      case .Failure(_):
        weakSelf.showErrorMessage()
      }
    }
  }

  private func showErrorMessage() {
    listingsTableView.hidden = true
    errorMessageLabel.hidden = false
  }

  private func hideErrorMessage() {
    errorMessageLabel.hidden = true
  }

  private func insertLoadingFooterView(){
    let tableFooterView: UIView = UIView(frame: CGRectMake(0, 0, listingsTableView.frame.size.width, 50))
    let loadingView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    loadingView.startAnimating()
    loadingView.center = tableFooterView.center
    tableFooterView.addSubview(loadingView)
    listingsTableView.tableFooterView = tableFooterView
  }

  private func removeLoadingFooterView(){
    listingsTableView.tableFooterView?.removeFromSuperview()
  }
}

extension ListingsViewController: FiltersViewDelegate {
  
  func cancelSearch() {
    dismissViewControllerAnimated(true, completion: nil)
  }

  func searchWithFilters(filters: SearchFilters) {
    self.searchFilters = filters
    self.search()

    dismissViewControllerAnimated(true, completion: nil)
  }
}

extension ListingsViewController: UITableViewDataSource {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return result?.businesses?.count ?? 0
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    guard let
      cell = tableView.dequeueReusableCellWithIdentifier("listingTableCell", forIndexPath: indexPath) as? ListingTableCell,
      totalResults = result?.total,
      businesses = result?.businesses
    else {
      return ListingTableCell()
    }

    if businesses.count < totalResults.integerValue && businesses.count == indexPath.row + 1 {
      search(startIndex: businesses.count)
    }

    cell.business = businesses[indexPath.row]

    return cell
  }
}

extension ListingsViewController: UITableViewDelegate {

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    searchBar.resignFirstResponder()

    if let cell = tableView.cellForRowAtIndexPath(indexPath) {
      cell.selected = false
    }
  }
}

extension ListingsViewController: UISearchBarDelegate {

  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    search()
  }

  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.characters.count == 0 {
      search()
    }
  }

  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    search()
  }
}