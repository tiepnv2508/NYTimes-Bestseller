//
//  Category+CoreDataProperties.swift
//  Bestseller
//
//  Created by Kaka on 3/12/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var name: String?
    @NSManaged public var nameEncoded: String?
    @NSManaged public var updatedTime: Date?
}
