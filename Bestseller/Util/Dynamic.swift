//
//  Dynamic.swift
//  Bestseller
//
//  Created by Kaka on 3/11/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation

class Dynamic<T> {
    typealias Listener = (T) -> ()
    var listener: Listener?
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init (_ v: T) {
        value = v
    }
    
    func bind(_ listener: Listener?) {
        self.listener = listener
    }
    
    func bindAndFire(_ listener: Listener?) {
        bind(listener)
        listener?(value)
    }
}
