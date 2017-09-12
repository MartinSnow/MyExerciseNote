//
//  CoreDataStack.swift
//  MyExerciseNote
//
//  Created by Ma Ding on 17/9/8.
//  Copyright © 2017年 Ma Ding. All rights reserved.
//

import CoreData

// Mark: CoreDataStack

struct CoreDataStack {
    
    // Mark: Properties
    
    private let model: NSManagedObjectModel
    internal let coordinator: NSPersistentStoreCoordinator
    private let modelURL: URL
    internal let databaseURL: URL
    internal let persistingContext: NSManagedObjectContext
    internal let backgroundContext: NSManagedObjectContext
    let context: NSManagedObjectContext
    
    // Mark: Initializers
    
    init?(modelName: String) {
        
        // Assumes the model is in the main bundle
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("Unable to find \(modelName) in the main bundle")
            return nil
        }
        self.modelURL = modelURL
        
        // Try to create the model from the URL
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("Unable to create a model from \(modelURL)")
            return nil
        }
        self.model = model
        
        // Create the store coordinator
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // Create a persistingContext (private queue) and a child one (main queue)
        // Create a context and add connect it to the coordinator
        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext.persistentStoreCoordinator = coordinator
        
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = persistingContext
        
        // Create a background context child of main context
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context
        
        // Add a SQLite store located in the documents folder
        let fileManager = FileManager.default
        
        guard let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to reach the documents folder")
            return nil
        }
        self.databaseURL = documentURL.appendingPathComponent("model.sqlite")
        
        // Options for migration
        let options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        
        do {
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: databaseURL, options: options as [NSObject: AnyObject]?)
        } catch {
            print("Unable to add store at \(databaseURL)")
        }
    
    }
    
    // Mark: Utils
    
    func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options: [NSObject:AnyObject]?) throws {
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: databaseURL, options: nil)
    }

}

// Mark: CoreDataStack (Removing Data)

internal extension CoreDataStack {
    
    func dropAllData() throws {
        // Delete all the objects in the database. This won't delete the files, it will just leave empty tables.
        try coordinator.destroyPersistentStore(at: databaseURL, ofType: NSSQLiteStoreType, options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: databaseURL, options: nil)
    }
}

// Mark: CoreDataStack (Batch Processing in the Background)

extension CoreDataStack {

    typealias Batch = (_ workerContext: NSManagedObjectContext) -> ()
    
    func performBackgroundBatchOperation(_ batch: @escaping Batch) {
    
        backgroundContext.perform() {
            
            batch(self.backgroundContext)
            
            // Save it to the parent context, so normal saving can work
            do {
                try self.backgroundContext.save()
            } catch {
                fatalError("Error while saving backgroundContext: \(error)")
            }
        }
    }
}

// Mark: CoreDataStack (Save Data)

extension CoreDataStack {
    
    func save() {
        // We call this synchronously, but it's a very fast operation (it doesn't hit the disk). We need to know when it ends so we can call the next save (on the persisting context). This last one might take time and is done in a background queue
        context.performAndWait() {
            
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    fatalError("Error while saving main context: \(error)")
                }
                
                // now we save in the background
                self.persistingContext.perform {
                    do {
                        try self.persistingContext.save()
                    } catch {
                        fatalError("Error while saving persisting context: \(error)")
                    }
                }
            }
        }
    }
    
    func autoSave(_ delayInSeconds: Int) {
        
        if delayInSeconds > 0 {
            do {
                try self.context.save()
                print("Autosaving")
            } catch {
                print("Error while autosaving")
            }
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.autoSave(delayInSeconds)
            }
        }
    }

}
