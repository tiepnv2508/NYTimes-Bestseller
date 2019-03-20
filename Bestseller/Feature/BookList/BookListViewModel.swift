//
//  BookListViewModel.swift
//  Bestseller
//
//  Created by Kaka on 3/11/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation
import CoreData

class BookListViewModel: NSObject {
    let bookListCellIdentifier: String
    let category: Category
    let categoryCode: String
    let updatedResultController: Dynamic<Bool>
    
    let reachability = Reachability()!
    var isPendingUpdate = false
    
    var orderBy: String {
        didSet {
            let isAscending = self.orderBy == GlobalConstants.kOrderByRank ? true : false
            resultController.fetchRequest.sortDescriptors = [NSSortDescriptor(key: self.orderBy, ascending: isAscending)]
            do {
                try resultController.performFetch()
            } catch let error {
                print("Fetch Error: \(error.localizedDescription)")
            }
        }
    }
    
    lazy var resultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Book.self))
        let isAscending = self.orderBy == GlobalConstants.kOrderByRank ? true : false
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: self.orderBy, ascending: isAscending)]
        fetchRequest.predicate = NSPredicate(format: "category.nameEncoded == %@", categoryCode)
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }()
    
    // MARK: -  Init
    
    init(_ category: Category) {
        self.bookListCellIdentifier = "BookListCellIdentifier"
        self.category = category
        self.categoryCode = category.nameEncoded!
        self.updatedResultController = Dynamic(false)
        self.orderBy = UserDefaults.standard.string(forKey: GlobalConstants.kOrderBy) ?? GlobalConstants.kOrderByRank
        super.init()
        setupReachability()
    }
    
    // MARK: -  Setup Reachability
    
    private func setupReachability() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi, .cellular:
            if isPendingUpdate {
                self.updateBookList()
            }
        case .none:
            print("Network not reachable")
        }
    }
    
    // MARK: -  Data
    
    private func updateBookList() {
        isPendingUpdate = true
        let service = APIService()
        service.getBookListsWith(category: categoryCode, completion: { [weak self](result) in
            switch result {
            case .Success(let results):
                self?.clearData()
                self?.saveToCoreDataWith(array: results)
                // execute update book list in the next 7 days
                DispatchQueue.main.asyncAfter(deadline: .now() + 604800) { [weak self] in
                    self?.updateBookList()
                }
                self?.isPendingUpdate = false
            case .Error(let error):
                print(error)
            }
        })
    }
    
    private func dataNeedUpdate() -> Bool {
        if let lastUpdate = category.updatedTime {
            //If the last time update local data >= 7 days,
            //then pull data from server and update local data.
            if lastUpdate.isOutOfDate() {
                return true
            } else {
                // execute update book list when reach 7 days from the last update
                let offsetTime = 604800 - lastUpdate.diffInSec()
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(offsetTime)) { [weak self] in
                    self?.updateBookList()
                }
            }
        } else {
            return true
        }
        return false
    }
    
    func initializeFetchController(aDelegate: NSFetchedResultsControllerDelegate) {
        resultController.delegate = aDelegate
        
        //Prefetch data from local
        do {
            try resultController.performFetch()
        } catch let error {
            print("Fetch Error: \(error.localizedDescription)")
        }
        
        //Get data from server side
        if self.dataNeedUpdate() {
            self.updateBookList()
        }
    }
    
    private func createBookEntityFrom(dictionary: [String: Any]) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        let book = Book(context: context)
        book.rank = dictionary["rank"] as! Int16
        book.weeksOnList = dictionary["weeks_on_list"] as! Int16
        book.title = dictionary["title"] as? String
        book.desc = dictionary["description"] as? String
        book.author = dictionary["author"] as? String
        book.amazonUrl = dictionary["amazon_product_url"] as? String
        book.reviewUrl = dictionary["book_review_link"] as? String
        category.updatedTime = Date()
        book.category = category
        return book
    }
    
    private func saveToCoreDataWith(array: [[String: Any]]) {
        _ = array.map{self.createBookEntityFrom(dictionary: $0)}
        do {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
    }
    
    private func clearData() {
        do {
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Book.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "category.nameEncoded == %@", categoryCode)
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                CoreDataStack.sharedInstance.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    // MARK: -  deinit
    
    deinit {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
}
