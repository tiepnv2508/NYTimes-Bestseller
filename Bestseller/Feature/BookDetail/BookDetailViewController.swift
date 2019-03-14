//
//  BookDetailViewController.swift
//  Bestseller
//
//  Created by Kaka on 3/11/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation
import UIKit

class BookDetailViewController: UIViewController {
    @IBOutlet weak var lbBookTitle: UILabel!
    @IBOutlet weak var lbAuthorName: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var txtAmazonUrl: UITextView!
    @IBOutlet weak var txtReviewUrl: UITextView!
    @IBOutlet weak var lbReview: UILabel!
    @IBOutlet weak var lbRank: UILabel!
    @IBOutlet weak var lbWeeksOnList: UILabel!
    
    var viewModel: BookDetailViewModel?
    
    // MARK: -  Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    // MARK: -  Setup
    func setup() {
        self.lbBookTitle.text = self.viewModel?.book.title
        self.lbAuthorName.text = self.viewModel?.book.author
        self.txtAmazonUrl.text = self.viewModel?.book.amazonUrl
        if let rank = self.viewModel?.book.rank {
            self.lbRank.text = "\(rank)"
        }
        if let weeksOnList = self.viewModel?.book.weeksOnList {
            self.lbWeeksOnList.text = "\(weeksOnList)"
        }
        
        // Show description if have a description
        if let description = self.viewModel?.book.desc {
            if description.count != 0 {
                self.txtDescription.text = description
                self.lbDescription.isHidden = false
            }
        }
        
        // Show review link if have a review link
        if let reviewUrl = self.viewModel?.book.reviewUrl {
            if reviewUrl.count != 0 {
                self.txtReviewUrl.text = reviewUrl
                self.txtReviewUrl.isHidden = false
                self.lbReview.isHidden = false
            } else {
                //Set new position for description section if doesn't have review link
                for constraint in self.view.constraints {
                    if constraint.identifier == "topDesAmzUrlConstraint" {
                        constraint.constant = 8
                    }
                }
                self.lbDescription.layoutIfNeeded()
            }
        }
    }
}
