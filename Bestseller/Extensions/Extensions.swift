//
//  Extensions.swift
//  Bestseller
//
//  Created by Kaka on 3/12/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation

extension Date {
    func isOutOfDate() -> Bool {
        let diffInDays = Calendar.current.dateComponents([.day], from: self, to: Date()).day
        if diffInDays ?? 0 >= 7 { return true }
        return false
    }
    
    func diffInSec() -> Int {
        return Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
    }
}
