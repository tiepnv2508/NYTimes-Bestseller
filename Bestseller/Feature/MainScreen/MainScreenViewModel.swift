//
//  MainScreenViewModel.swift
//  Bestseller
//
//  Created by Kaka on 3/11/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation
import CoreData

class MainScreenViewModel: NSObject {
    let categoryCellIdentifier: String
    var onErrorHandling : ((String?) -> Void)?
    let dispatchQueue: DispatchQueue
    var isQueueSuspended: Bool
    
    lazy var resultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Category.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }()
    
    // MARK: -  Init
    
    override init() {
        self.categoryCellIdentifier = "CategoryCellIdentifier"
        self.dispatchQueue = DispatchQueue(label: "mainScreenQueue")
        self.isQueueSuspended = false
    }
    
    // MARK: -  Data
    
    private func updateCategories() {
        let service = APIService()
        service.getBookCategories { [weak self](result) in
            switch result {
            case .Success(let results):
                self?.clearData()
                self?.saveToCoreDataWith(array: results)
                // execute update categories in the next 7 days
                self?.dispatchQueue.asyncAfter(deadline: .now() + 604800) { [weak self] in
                    self?.updateCategories()
                }
            case .Error(let error):
                self?.onErrorHandling?(error)
            }
        }
    }
    
    private func dataNeedUpdate() -> Bool {
        if let lastUpdate = UserDefaults.standard.object(forKey: GlobalConstants.kLastTimeUpdateCategories) as? Date {
            //If the last time update local data >= 7 days, then update local data.
            if lastUpdate.isOutOfDate() {
                return true
            } else {
                // execute update categories when reach 7 days from the last update
                let offsetTime = 604800 - lastUpdate.diffInSec()
                self.dispatchQueue.asyncAfter(deadline: .now() + .seconds(offsetTime)) { [weak self] in
                    self?.updateCategories()
                }
            }
        } else {
            //First time using app, pull data from server and save data locally
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
            self.updateCategories()
        }
    }
    
    private func createCategoryEntityFrom(dictionary: [String: Any]) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        let category = Category(context: context)
        category.name = dictionary["list_name"] as? String
        category.nameEncoded = dictionary["list_name_encoded"] as? String
        return category
    }
    
    private func saveToCoreDataWith(array: [[String: Any]]) {
        _ = array.map{self.createCategoryEntityFrom(dictionary: $0)}
        do {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
            UserDefaults.standard.set(Date(), forKey: GlobalConstants.kLastTimeUpdateCategories)
        } catch let error {
            print(error)
        }
    }
    
    private func clearData() {
        do {
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                CoreDataStack.sharedInstance.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
}
