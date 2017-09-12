//
//  Note+CoreDataProperties.swift
//  MyExerciseNote
//
//  Created by Ma Ding on 17/9/8.
//  Copyright © 2017年 Ma Ding. All rights reserved.
//

import Foundation
import CoreData
import 

extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note");
    }

    @NSManaged public var text: String?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var notebook: Notebook?

}
