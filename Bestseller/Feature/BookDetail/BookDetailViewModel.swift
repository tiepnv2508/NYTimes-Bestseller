//
//  BookDetailViewModel.swift
//  Bestseller
//
//  Created by Kaka on 3/11/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation

class BookDetailViewModel: NSObject {
    let book: Book
    
    // MARK: -  Init
    
    init(_ book: Book) {
        self.book = book
    }
}
