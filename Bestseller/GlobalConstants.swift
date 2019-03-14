//
//  AppConfig.swift
//  Bestseller
//
//  Created by Kaka on 3/12/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation

struct GlobalConstants {
    // API key for NYTimes Book
    static let api_key = "WMDHlNAtf8f3omYoG2bRRiyxcqSgWxZj"
    static let book_api_domain = "https://api.nytimes.com/svc/books/v3/"
    static let get_book_categories = "lists/names.json?api-key=%@"
    static let get_book_list = "lists/current/%@.json?api-key=%@"
    
    // Keys
    static let kLastTimeUpdateCategories = "lastTimeUpdateCategories"
    static let kOrderBy = "orderBy"
    static let kOrderByRank = "rank"
    static let kOrderByWeeksOnList = "weeksOnList"
}
