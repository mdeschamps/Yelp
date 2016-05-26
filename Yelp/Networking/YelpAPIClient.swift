//
//  YelpAPIClient.swift
//  Yelp
//
//  Created by Manuel Deschamps on 5/24/16.
//  Copyright © 2016 deschamps. All rights reserved.
//

import Foundation
import OAuthSwift

enum SearchResponse {
  case Success(result: SearchResult)
  case Failure(error: NSError)
}

class YelpAPIClient {

  private static let consumerKey	= "a-DMZ-gEJIN0FkT0pMIb4A"
  private static let consumerSecret = "hXi3aJlxR8APMKSg3iVazki3GTI"
  private static let accessToken = "kIr0QMvjPE9UaPuiwWoi6FY8NhvgnXkm"
  private static let accessTokenSecret = "1bsx-AY_ghXH-NTObj8FPzCvRh0"

  private var client: OAuthSwiftClient
  private let baseUrl = NSURL(string: "https://api.yelp.com")!
  private let searchPath = "/v2/search"

  internal init(){
    client = OAuthSwiftClient(
      consumerKey: YelpAPIClient.consumerKey,
      consumerSecret: YelpAPIClient.consumerSecret,
      accessToken: YelpAPIClient.accessToken,
      accessTokenSecret: YelpAPIClient.accessTokenSecret)
  }

  func search(startIndex offset: Int, term searchTerm: String?, filters: SearchFilters?, completion: (result: SearchResponse) -> Void) {
    let searchUrlComponents =  NSURLComponents(URL: baseUrl, resolvingAgainstBaseURL: true)
    searchUrlComponents?.path = searchPath

    guard let searchUrl = searchUrlComponents?.URL?.absoluteString else {
      completion(result: .Failure(error: NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
      return
    }

    var parameters: [String: String] = [:]

    filters?.filters.forEach { (type, filter) in
      if let name = filter.name, value = filter.value {
        parameters[name] = value
      }
    }

    if offset > 0 {
      parameters["offset"] = String(offset)
    }

    if let term = searchTerm {
      parameters["term"] = term
    }
    parameters["ll"] = "37.785771,-122.406165" // SF

    client.get(searchUrl, parameters: parameters, headers: nil,
      success: { (data, response) in
        let dataString = String(data: data, encoding: NSUTF8StringEncoding)
        let result = SearchResult(json: dataString)
        completion(result: .Success(result: result))
      },
      failure: { (error) in
        completion(result: .Failure(error: error))
      }
    )
  }
}
