//
//  Move.swift
//  Note_FinalProject
//
//  Created by Harkirat on 6/27/20.
//  Copyright © 2020 Harkirat Singh. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Move: UIViewController {
    
    var folders = [Folder]()
    var selectedNotes: [Notes]? {
        didSet {
            loadFolders()
        }
    }
    
    // create a context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - data manipulation core data
    
    func loadFolders() {
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        
        // Predicate  if you want
        let folderPredicate = NSPredicate(format: "NOT name MATCHES %@", selectedNotes?[0].folder?.name ?? "")
        request.predicate = folderPredicate
        
        do {
            folders = try context.fetch(request)
            print(folders.count)
        } catch {
            print("Error fetching data \(error.localizedDescription)")
        }
    }


    @IBAction func dismissVC(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension Move: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "")
        cell.textLabel?.text = folders[indexPath.row].name
        cell.backgroundColor = .darkGray
        cell.textLabel?.textColor = .white
       // cell.tintColor = .lightText
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Move to \(folders[indexPath.row].name!)", message: "Are you sure?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Move", style: .default) { (action) in
            for note in self.selectedNotes! {
                note.folder = self.folders[indexPath.row]
            }
            self.performSegue(withIdentifier: "dismissMoveToVC", sender: self)
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        noAction.setValue(UIColor.orange, forKey: "titleTextColor")
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
    }
}

