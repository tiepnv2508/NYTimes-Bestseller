//
//  Result.swift
//  Bestseller
//
//  Created by Kaka on 3/12/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation

enum Result<T> {
    case Success(T)
    case Error(String)
}
