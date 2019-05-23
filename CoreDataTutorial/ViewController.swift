//
//  ViewController.swift
//  CoreDataTutorial
//
//  Created by Parshva Shah on 5/24/19.
//  Copyright © 2019 Parshva Shah. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var tasks: [NSManagedObject] = []
    
    var myTableView = UITableView()
    //var tableData = ["Beach", "Clubs", "Chill", "Dance"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addButton()
        myTableView = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.contentInset.top = 20
        myTableView.backgroundColor = .white
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        myTableView.tableFooterView = UIView()
        
        view.addSubview(myTableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Tasks")
        
        //3
        do {
            tasks = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return tableData.count
        return tasks.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //cell.textLabel?.text = "\(tableData[indexPath.row])"
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.value(forKeyPath: "task") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            do {
                let taskToDelete = tasks[indexPath.row]
                
                managedContext.delete(taskToDelete)
                tasks.remove(at: indexPath.row)
                myTableView.reloadData()
                do {
                    try managedContext.save()
                } catch {
                    print(error)
                }
            } catch {
                print(error)
            }
        default:
            return
        }
    }
    
    func addButton(){
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.addTask))
        self.navigationItem.rightBarButtonItem = button
    }
    
    @objc func addTask(){
        let alertController = UIAlertController(title: "Add Task", message: "", preferredStyle: .alert)
        alertController.addTextField{(textField) in
            textField.placeholder = "Task"
        }
        
        let save = UIAlertAction(title: "Save", style: .default) { (_) in
            let textField = alertController.textFields?.first
            
            self.save(name: textField!.text!)
            self.myTableView.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alertController.addAction(save)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    func save(name: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext

        let entity =
            NSEntityDescription.entity(forEntityName: "Tasks",
                                       in: managedContext)!
        
        let tasksCore = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        tasksCore.setValue(name, forKeyPath: "task")
        
        do {
            try managedContext.save()
            tasks.append(tasksCore)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

