//
//  Note+CoreDataClass.swift
//  MyExerciseNote
//
//  Created by Ma Ding on 17/9/8.
//  Copyright © 2017年 Ma Ding. All rights reserved.
//

import Foundation
import CoreData

// Mark: Note: NSManagedObject

public class Note: NSManagedObject {
    
    //Mark: Initializer
    
    convenience init(text: String = "New Note", context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all the information you provide in the Entity part of the model, you need it to create an instance of this class.
        if let entity = NSEntityDescription.entity(forEntityName: "Note", in: context) {
            self.init(entity: entity, insertInto: context)
            self.text = text
            self.creationDate = Date() as NSDate?
        } else {
            fatalError("Unable to find Entity name!")
        }
    
    }

}
