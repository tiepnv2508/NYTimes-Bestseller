//
//  Book+CoreDataProperties.swift
//  Bestseller
//
//  Created by Kaka on 3/12/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//
//

import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var amazonUrl: String?
    @NSManaged public var author: String?
    @NSManaged public var desc: String?
    @NSManaged public var rank: Int16
    @NSManaged public var reviewUrl: String?
    @NSManaged public var title: String?
    @NSManaged public var weeksOnList: Int16
    @NSManaged public var category: Category?
    
}
