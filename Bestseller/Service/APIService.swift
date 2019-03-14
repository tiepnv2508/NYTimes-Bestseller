//
//  APIService.swift
//  Bestseller
//
//  Created by Kaka on 3/11/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation
import UIKit

class APIService: NSObject {
    typealias getBookCategoriesHandler = (Result<[[String: Any]]>) -> Void
    typealias getBookListHandler = (Result<[[String: Any]]>) -> Void
    
    func getBookCategories(completion: @escaping getBookCategoriesHandler) {
        let urlString = String(format: GlobalConstants.book_api_domain + GlobalConstants.get_book_categories, GlobalConstants.api_key)
        guard let url = URL(string: urlString) else {
            return completion(.Error("Invalid URL, can't get data"))
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else { return completion(.Error(error!.localizedDescription)) }
            guard let data = data else {
                return completion(.Error(error?.localizedDescription ?? "There isn't any category"))
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: Any] {
                    guard let categoriesJsonArray = json["results"] as? [[String: Any]] else {
                        return completion(.Error(error?.localizedDescription ?? "There isn't any category"))
                    }
                    DispatchQueue.main.async {
                        completion(.Success(categoriesJsonArray))
                    }
                }
            } catch let error {
                return completion(.Error(error.localizedDescription))
            }
        }.resume()
    }
    
    func getBookListsWith(category: String, completion: @escaping getBookListHandler) {
        let urlString = String(format: GlobalConstants.book_api_domain + GlobalConstants.get_book_list, category, GlobalConstants.api_key)
        guard let url = URL(string: urlString) else {
            return completion(.Error("Invalid URL, can't get data"))
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else { return completion(.Error(error!.localizedDescription)) }
            guard let data = data else {
                return completion(.Error(error?.localizedDescription ?? "There isn't any book of category \(category)"))
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: Any] {
                    guard let resultArray = json["results"] as? [String: Any],
                          let booksJsonArray = resultArray["books"] as? [[String: Any]] else {
                        return completion(.Error(error?.localizedDescription ?? "There isn't any book of category \(category)"))
                    }
                    DispatchQueue.main.async {
                        completion(.Success(booksJsonArray))
                    }
                }
            } catch let error {
                return completion(.Error(error.localizedDescription))
            }
        }.resume()
    }
}
