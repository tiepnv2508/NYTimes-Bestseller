//
//  Helper.swift
//  Bestseller
//
//  Created by Kaka on 3/12/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation
import UIKit

class Helper: NSObject {
    static let sharedInstance = Helper()
    override init() {}
    
    func showAlertWith(title: String, message: String, viewController: UIViewController){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            viewController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        viewController.present(alertController, animated: true, completion: nil)
    }
}
