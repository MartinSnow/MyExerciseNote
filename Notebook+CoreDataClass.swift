//
//  Notebook+CoreDataClass.swift
//  MyExerciseNote
//
//  Created by Ma Ding on 17/9/8.
//  Copyright © 2017年 Ma Ding. All rights reserved.
//

import Foundation
import CoreData


public class Notebook: NSManagedObject {
    
    // MARK: Initializer
    
    convenience init(name: String, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all the information you provide in the Entity part of the model, you need it to create an instance of this class.
        if let entity = NSEntityDescription.entity(forEntityName: "Notebook", in: context) {
            self.init(entity: entity, insertInto: context)
            self.name = name
            self.creationDate = Date() as NSDate?
        } else {
            fatalError("Unable to find Entity name!")
        }
    
    }

}
