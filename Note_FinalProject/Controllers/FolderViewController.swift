//
//  ViewController.swift
//  Note_FinalProject
//
//  Created by Harkirat Singh on 2020-06-20.
//  Copyright © 2020 Harkirat Singh. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
class FolderViewController: UITableViewController {
     // create a folder array to populate the table
    var folders = [Folder]()
    var Array = [Notes]()
       
       // create a context
       let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

       override func viewDidLoad() {
           super.viewDidLoad()
           print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
           loadFolder()
        Notifications()
        
       }
       
       override func viewWillAppear(_ animated: Bool) {
           tableView.reloadData()
       }
       
       //MARK: - Data manipulation methods
       
       func loadFolder() {
           let request: NSFetchRequest<Folder> = Folder.fetchRequest()
           
           do {
               folders = try context.fetch(request)
           } catch {
               print("Error loading folders \(error.localizedDescription)")
           }
           
           tableView.reloadData()
       }
       
       func saveFolders() {
           do {
               try context.save()
               tableView.reloadData()
           } catch {
               print("Error saving folders \(error.localizedDescription)")
           }
       }

       // MARK: - Table view data source

       override func numberOfSections(in tableView: UITableView) -> Int {
           // #warning Incomplete implementation, return the number of sections
           return 1
       }

       override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           // #warning Incomplete implementation, return the number of rows
           return folders.count
       }

       
       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "folderCell", for: indexPath)
           cell.textLabel?.text = folders[indexPath.row].name
           cell.textLabel?.textColor = .black
           cell.detailTextLabel?.textColor = .black
           cell.detailTextLabel?.text = "\(folders[indexPath.row].notes?.count ?? 0)"
           cell.imageView?.image = UIImage(systemName: "folder")
           cell.selectionStyle = .none
           return cell
       }

       //Code For add folder method
       @IBAction func addFolder(_ sender: UIBarButtonItem) {
           
           var textField = UITextField()
           let alert = UIAlertController(title: "Add New Folder", message: "", preferredStyle: .alert)
           let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
               let folderNames = self.folders.map {$0.name}
            guard !folderNames.contains(textField.text) else {self.showAlert(); return}
               let newFolder = Folder(context: self.context)
               newFolder.name = textField.text!
               self.folders.append(newFolder)
               self.saveFolders()
           }
           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
           // change the font color of cancel action
           cancelAction.setValue(UIColor.orange, forKey: "titleTextColor")
           
           alert.addAction(addAction)
           alert.addAction(cancelAction)
           alert.addTextField { (field) in
               textField = field
               textField.placeholder = "Folder Name"
           }
           
           present(alert, animated: true, completion: nil)
       }
       // Alert Box
      func showAlert() {
          let alert = UIAlertController(title: "Name Taken", message: "Please choose another name", preferredStyle: .alert)
          
          let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
          okAction.setValue(UIColor.orange, forKey: "titleTextColor")
          alert.addAction(okAction)
          present(alert, animated: true, completion: nil)
      }
       //Performing segue
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           let destination = segue.destination as! NoteTableViewController
           if let indexPath = tableView.indexPathForSelectedRow {
               destination.selectedFolder = folders[indexPath.row]
           }
           
       }

     func Notifications() {
            
           let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let request: NSFetchRequest<Notes> = Notes.fetchRequest()
                do {
                    let notifications = try context.fetch(request)
                    for task in notifications {
                        if Calendar.current.isDateInTomorrow(task.dateSelect!) {
                            Array.append(task)
                        }
                    }
                } catch {
                    print("Error loading todos \(error.localizedDescription)")
                }
                
        if Array.count > 0 {
        for task in Array {
        if let name = task.title {
        let notificationCenter = UNUserNotificationCenter.current()
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Task Reminder"
        notificationContent.body = "This message is to remind that \(name) is due tommorow"
        notificationContent.sound = .default
         let fromDate = Calendar.current.date(byAdding: .day, value: -1, to: task.dateSelect!)!
        let components = Calendar.current.dateComponents([.month, .day, .year], from: fromDate)
         let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "\(name)task", content:notificationContent, trigger: trigger)
        notificationCenter.add(request) { (error) in
                            if error != nil {
                                print(error ?? "notification center error")
                            }
                        }
                    }
                }
            }
            
        }
    

}

