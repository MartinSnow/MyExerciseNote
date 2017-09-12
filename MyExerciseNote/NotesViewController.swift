//
//  NotesViewController.swift
//  MyExerciseNote
//
//  Created by Ma Ding on 17/9/9.
//  Copyright © 2017年 Ma Ding. All rights reserved.
//

import UIKit

// Mark: NotesViewController: CoreDataTableViewController

class NotesViewController: CoreDataTableViewController {
    
    // Mark: Properties
    
    var notebook: Notebook?
    
    // Mark: Actions
    
    @IBAction func addNewNote(_ sender: AnyObject) {
        
        /*if let nb = notebook, let context = fetchedResultsController?.managedObjectContext {
            // Just create a new note and you're done!
            let note = Note(text: "New Note", context: context)
            note.notebook = nb
            print("Just created a note: \(note)")
        }*/
        
        // Create a new notebook... and Core Data takes care of the rest!
        let note = Note(text: "New Note", context: fetchedResultsController!.managedObjectContext)
        note.notebook = notebook
        print("Just created a note: \(note)")
    }

    // Mark: TableView Data Source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get the note
        let note = fetchedResultsController?.object(at: indexPath) as! Note
        
        // Get the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)
        
        // Sync note -> cell
        cell.textLabel?.text = note.text
        
        // Return the cell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if let context = fetchedResultsController?.managedObjectContext, let note = fetchedResultsController?.object(at: indexPath) as? Note, editingStyle == .delete {
            context.delete(note)
        }
    }
    
}
