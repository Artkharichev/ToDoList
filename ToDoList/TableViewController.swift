//
//  TableViewController.swift
//  ToDoList
//
//  Created by Артём Харичев on 27.05.2020.
//  Copyright © 2020 Artem Kharichev. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
    
    var tasks: [Task] = []
    
    @IBAction func saveTask(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "New Task", message: "Please add new task", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            
            let textField = alertController.textFields?.first
            if let newTaskTitle = textField?.text {
                if newTaskTitle != "" {
                    self.saveTask(withTitle: newTaskTitle)
                    self.tableView.reloadData()
                }
            }
        }
        
        alertController.addTextField { _ in }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
        
    }
    
    private func saveTask(withTitle title:String){
        
        let context = getContext()
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        
        let taskObject = Task(entity: entity, insertInto: context)
        
        taskObject.title = title
        
        do {
            try context.save()
            tasks.insert(taskObject, at: 0)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let context = getContext()
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        /* let sortDiscripter = NSSortDescriptor(key: "title", ascending: true)
         fetchRequest.sortDescriptors = [sortDiscripter] */
        
        do {
            tasks = try context.fetch(fetchRequest)
        } catch let error as NSError{
            print(error.localizedDescription)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let context = getContext()
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        let deleteAction = UIContextualAction (style: .destructive, title: "Delete") { (_, _, _) in
            
            if let objects = try? context.fetch(fetchRequest) {
                context.delete(objects[indexPath.row])
            }
            
            do {
                try context.save()
                self.tasks.remove(at: indexPath.row)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let delete = UISwipeActionsConfiguration(actions: [deleteAction])
        return delete
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        
        return cell
    }
}
