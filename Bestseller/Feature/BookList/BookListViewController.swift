//
//  BookListViewController.swift
//  Bestseller
//
//  Created by Kaka on 3/11/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class BookListViewController: UIViewController, UIActionSheetDelegate {
    @IBOutlet weak var tableView: UITableView!
    var viewModel: BookListViewModel!
    
    // MARK: -  Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
        self.setupNavigation()
        self.setupUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let bookDetailVC = segue.destination as! BookDetailViewController
        let selectedIndex = self.tableView.indexPathForSelectedRow!
        let book = self.viewModel.resultController.object(at: selectedIndex) as! Book
        bookDetailVC.viewModel = BookDetailViewModel(book)
    }
    
    // MARK: - Navigation
    
    private func setupNavigation() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "sort"), style: .plain, target: self, action: #selector(showSortOptions))
    }
    
    // MARK: -  Setup UI
    
    private func setupUI() {
        self.title = self.viewModel.category.name
        self.tableView.tableFooterView = nil;
        self.viewModel.initializeFetchController(aDelegate: self)
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    private func bindViewModel() {
        self.viewModel.updatedResultController.bindAndFire { [weak self] value in
            UIView.transition(with: self!.tableView,
                              duration: 0.35,
                              options: .transitionCrossDissolve,
                              animations: { self?.tableView.reloadData() })
        }
    }
    
    // MARK: -  Action
    
    @objc private func showSortOptions() {
        var sortingBy = "Sorting by "
        if let orderBy = UserDefaults.standard.string(forKey: GlobalConstants.kOrderBy) {
            sortingBy += orderBy == GlobalConstants.kOrderByRank ? "Rank" : "Weeks on List"
        }
        
        let optionMenu = UIAlertController(title: sortingBy, message: nil, preferredStyle: .actionSheet)
        
        let sortByRank = UIAlertAction(title: "Sort by Rank", style: .default) { (action) in
            UserDefaults.standard.set(GlobalConstants.kOrderByRank, forKey: GlobalConstants.kOrderBy)
            self.viewModel.orderBy = GlobalConstants.kOrderByRank
            self.viewModel.updatedResultController.value = true
        }
        
        let sortByWeeksOnList = UIAlertAction(title: "Sort by Weeks on List", style: .default) { (action) in
            UserDefaults.standard.set(GlobalConstants.kOrderByWeeksOnList, forKey: GlobalConstants.kOrderBy)
            self.viewModel.orderBy = GlobalConstants.kOrderByWeeksOnList
            self.viewModel.updatedResultController.value = true
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(sortByRank)
        optionMenu.addAction(sortByWeeksOnList)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
}

// MARK: -  TableView DataSource & Delegate

extension BookListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = viewModel.resultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.bookListCellIdentifier, for: indexPath)
        
        if let book = viewModel.resultController.object(at: indexPath) as? Book {
            cell.textLabel?.text = book.title
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: -  FetchedResultsControllerDelegate

extension BookListViewController: NSFetchedResultsControllerDelegate {
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

