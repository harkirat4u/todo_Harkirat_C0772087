//
//  NoteTableViewController.swift
//  Note_FinalProject
//
//  Created by Harkirat Singh on 2020-06-21.
//  Copyright © 2020 Harkirat Singh. All rights reserved.
//

import UIKit
import CoreData
class NoteTableViewController: UITableViewController,UISearchResultsUpdating,UISearchBarDelegate {
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var array = [String]()
    @IBOutlet var searchbar: UISearchBar!
    var filteredArray = [String]()
    var searchController = UISearchController()
    var resultsController = UITableViewController()
    var notebook : Folder!
   
    @IBOutlet weak var deletebtn: UIBarButtonItem!
    @IBOutlet weak var movebtn: UIBarButtonItem!
    
    
    var editMode: Bool = false
    var issearch=false;
    var searchNote : [Notes] = []
    var notes = [Notes]()
    
       var selectedFolder: Folder? {
           didSet {
               loadNotes()
           }
       }
   
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchbar.delegate = self;
       // loadNotes()
    }
    
    @IBAction func btnSort(_ sender: UIBarButtonItem) {
        sortByTitle()
        tableView.reloadData()
        
    }
    func updateSearchResults(for searchController: UISearchController) {
        searchController.searchBar.autocapitalizationType = .none
        filteredArray = array.filter({ (array: String) -> Bool in
            if array.localizedCaseInsensitiveContains(searchController.searchBar.text!) {
                return true
            }
            else{
                return false
            }
        })
        resultsController.tableView.reloadData()
    }
    
    
    
    func sortByTitle(with request: NSFetchRequest<Notes> = Notes.fetchRequest(), predicate: NSPredicate? = nil) {
                   
                            let folderPredicate = NSPredicate(format: "folder.name=%@", selectedFolder!.name!)
                            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
                            if let addtionalPredicate = predicate {
                                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [folderPredicate, addtionalPredicate])
                            } else {
                                request.predicate = folderPredicate
                            }
                            
                            do {
                                notes = try context.fetch(request)
                            } catch {
                                print("Error loading notes \(error.localizedDescription)")
                            }
                            
                            tableView.reloadData()
                        }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        let serachDta = notes.filter { $0.title!.lowercased().contains(searchText.lowercased()) || $0.desc!.lowercased().contains(searchText.lowercased())}
        
        if serachDta.count>0
        {
            searchNote  = serachDta;
            issearch = true;
        }
        else
        {
            issearch = false;
        }
        self.tableView.reloadData()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool
    {
        return true;
    }
    
    
    
    @IBAction func editModePressed(_ sender: UIBarButtonItem) {
        editMode = !editMode
             
             tableView.setEditing(editMode ? true : false, animated: true)
             
             deletebtn.isEnabled = !deletebtn.isEnabled
             movebtn.isEnabled = !movebtn.isEnabled
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if tableView == resultsController.tableView{
            return filteredArray.count
        }
        else{
            return notes.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == resultsController.tableView {
            let celll = UITableViewCell()
            celll.textLabel?.text = filteredArray[indexPath.row]
            return celll
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell") as! NoteTableViewCell
            let unixTimestamp = notes[indexPath.row].created/1000;
            let date = Date(timeIntervalSince1970: TimeInterval(unixTimestamp));
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let strDate = dateFormatter.string(from: date)
            var date1 = NSDate()
            let dateto=notes[indexPath.row].dateSelect!
            cell.dateLbl.text = strDate
           cell.titleLbl.text = notes[indexPath.row].title!
            //cell.createdLbl.text = notes[indexPath.row].desc!
          
            
            if(dateto>date1 as Date){cell.backgroundColor = .green}
            else if(dateto<date1 as Date){cell.backgroundColor = .red}
            else{cell.backgroundColor = .orange}
            return cell
        }
        
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            deleteNote(note: notes[indexPath.row])
                      saveNotes()
                      notes.remove(at: indexPath.row)
                      // Delete the row from the data source
                      tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        
        searchController.searchBar.autocapitalizationType = .none
        
        searchController = UISearchController(searchResultsController: resultsController)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        
        resultsController.tableView.delegate = self
        resultsController.tableView.dataSource = self
      
        loadNotes()
        for note in self.notes {
            let unixTimestamp = note.created/1000;
            let date = Date(timeIntervalSince1970: TimeInterval(unixTimestamp));
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let strDate = dateFormatter.string(from: date)
            
            
            array.append("Search by Title \(note.title!)")
        }
        searchController.searchBar.autocapitalizationType = .none
        self.loadNotes()
        self.tableView.reloadData()
    }
    
    

        func loadNotes(with request: NSFetchRequest<Notes> = Notes.fetchRequest(), predicate: NSPredicate? = nil) {
       
                let folderPredicate = NSPredicate(format: "folder.name=%@", selectedFolder!.name!)
                request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
                if let addtionalPredicate = predicate {
                    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [folderPredicate, addtionalPredicate])
                } else {
                    request.predicate = folderPredicate
                }
                
                do {
                    notes = try context.fetch(request)
                } catch {
                    print("Error loading notes \(error.localizedDescription)")
                }
                
                tableView.reloadData()
            }
    
    
     func deleteNote(note: Notes) {
         context.delete(note)
     }
        func saveNotes() {
            do {
                try context.save()
            } catch {
                print("Error saving the context \(error.localizedDescription)")
            }
        }
        
        //MARK: - update note
        func updateNote(with title: String) {
            notes = []
            let newNote = Notes(context: context)
            newNote.title = title
            newNote.folder = selectedFolder
            notes.append(newNote)
            saveNotes()
            loadNotes()
        }
        //MARK: - unwind segue
        @IBAction func unwindToNoteTableVC(_ unwindSegue: UIStoryboardSegue) {
    //        let sourceViewController = unwindSegue.source
            // Use data from the view controller which initiated the unwind segue
            
            saveNotes()
            loadNotes()
            tableView.setEditing(false, animated: false)
        }
    
    
    @IBAction func deleteNotes(_ sender: UIBarButtonItem) {
        
        if let indexPaths = tableView.indexPathsForSelectedRows {
            let rows = (indexPaths.map {$0.row}).sorted(by: >)
            
            let _ = rows.map {deleteNote(note: notes[$0])}
            let _ = rows.map {notes.remove(at: $0)}
            
            tableView.reloadData()
            
            saveNotes()
        }
    }
     
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
           guard identifier != "moveNoteSegue" else {
               return true
           }
           return editMode ? false : true
       }
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        

        if (segue.identifier == "addNote") {
            let editNoteVC = segue.destination as! AddNoteVC
            editNoteVC.userIsEditing = false
            editNoteVC.folder = selectedFolder
            
        }
        else  if (segue.identifier == "editNote") {
            
            let editNoteVC = segue.destination as! AddNoteVC
              editNoteVC.folder = selectedFolder
            let i = (self.tableView.indexPathForSelectedRow?.row)!
            editNoteVC.note = notes[i]
            
        }
        
        
        if let destination = segue.destination as? Move {
                  if let indexPaths = tableView.indexPathsForSelectedRows {
                      let rows = indexPaths.map {$0.row}
                      destination.selectedNotes = rows.map {notes[$0]}
                  }
              }
    }
    
    
}

