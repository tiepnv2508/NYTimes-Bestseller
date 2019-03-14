//
//  MainScreenViewController.swift
//  Bestseller
//
//  Created by Kaka on 3/11/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class MainScreenViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var viewModel: MainScreenViewModel!
    
    // MARK: -  Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let bookListVC = segue.destination as! BookListViewController
        let selectedIndex = self.tableView.indexPathForSelectedRow!
        let category = viewModel.resultController.object(at: selectedIndex) as! Category
        bookListVC.viewModel = BookListViewModel(category)
    }
    
    // MARK: -  Setup UI
    
    private func setupUI() {
        // Set Sort by Rank option for the first time.
        if let _ = UserDefaults.standard.string(forKey: GlobalConstants.kOrderBy) {
        } else {
            UserDefaults.standard.set(GlobalConstants.kOrderByRank, forKey: GlobalConstants.kOrderBy)
        }
        
        // Initialize View Model
        viewModel = MainScreenViewModel()
        
        // Show alert if have any error when pull data from server
        self.viewModel.onErrorHandling = { [weak self] error in
            Helper.sharedInstance.showAlertWith(title: "Error", message: error!, viewController: self!)
        }
        
        // Initialize Fetch Controller
        self.viewModel.initializeFetchController(aDelegate: self)
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero);
    }
}

// MARK: -  TableView DataSource & Delegate

extension MainScreenViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = viewModel.resultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.categoryCellIdentifier, for: indexPath)
        
        if let category = viewModel.resultController.object(at: indexPath) as? Category {
            cell.textLabel?.text = category.name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: -  FetchedResultsControllerDelegate

extension MainScreenViewController: NSFetchedResultsControllerDelegate {
    // Notifies the receiver that a fetched object has been changed
    // due to an add, remove, move, or update.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
}
