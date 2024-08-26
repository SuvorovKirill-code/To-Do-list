//
//  MainTableViewController.swift
//  ToDoList
//
//  Created by Kirill Suvorov on 23.08.2024.
//

import UIKit
import CoreData

class MainTableViewController: UITableViewController {

    var tasks: [Task] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let context = getContext()
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            tasks = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func getContext() -> NSManagedObjectContext {
        let appDeligate = UIApplication.shared.delegate as! AppDelegate
        return appDeligate.persistentContainer.viewContext
    }
    
    @IBAction func addTask(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "New task", message: "Pleace add new task", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let textField = alertController.textFields?.first
            if let newTask = textField?.text {
                self.saveTask(withTitle: newTask)
                self.tableView.reloadData()
            }
        }
        
        alertController.addTextField()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true)
    }
    
    private func saveTask(withTitle title: String) {
        
        let context = getContext()
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        
        let taskObject = Task(entity: entity, insertInto: context)
        taskObject.title = title
        
        do {
            try context.save()
            tasks.append(taskObject)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
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

        var content = cell.defaultContentConfiguration()
        let task = tasks[indexPath.row]
        content.text = task.title
        
        cell.contentConfiguration = content
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let context = getContext()
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            
            do {
                tasks.remove(at: indexPath.row)
                let objects = try context.fetch(fetchRequest)
                let objectToDelete = objects[indexPath.row]
                context.delete(objectToDelete)

                try context.save()

                tableView.deleteRows(at: [indexPath], with: .automatic)
                
            } catch let error as NSError {
                print("Could not fetch or delete: \(error), \(error.userInfo)")
            }
        }
    }
    
    
}
