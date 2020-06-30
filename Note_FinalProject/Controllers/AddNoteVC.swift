//
//  AddNoteVC.swift
//  Note_FinalProject
//
//  Created by Harkirat Singh on 2020-06-21.
//  Copyright © 2020 Harkirat Singh. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation
import AVFoundation


class AddNoteVC: UIViewController, CLLocationManagerDelegate,UIImagePickerControllerDelegate ,UINavigationControllerDelegate, AVAudioRecorderDelegate, UITextFieldDelegate{
    var selectedNote: Notes?
      weak var delegate: NoteTableViewController?
    @IBOutlet var txttitle: UITextField!
    @IBOutlet var txtDesc: UITextView!

    @IBOutlet weak var savebtn: UIBarButtonItem!
    @IBOutlet weak var update: UIBarButtonItem!
    @IBOutlet weak var textField_Date: UITextField!
     var datePicker : UIDatePicker!
    var listArray = [NSManagedObject]();
    var note:Notes!
    var folder : Folder?
    var userIsEditing = true
    var context:NSManagedObjectContext!
    override func viewDidLoad() {
        super.viewDidLoad()
        textField_Date.delegate = self
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        context = appDelegate.persistentContainer.viewContext
        if (userIsEditing == true) {
           let dateselected = note.dateSelect!
           let dateFormatter1 = DateFormatter()
             dateFormatter1.dateFormat = "dd-MM-yyyy HH:mm"
            var date1 = dateFormatter1.string(from: dateselected)
            txttitle.text = note.title!
            txtDesc.text = note.desc!
            textField_Date.text = date1
            txttitle.text = note.title!
            txtDesc.text = note.desc!
           
            
        }
        else {
            txtDesc.text = ""
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField)
           {
                 self.pickUpDate(self.textField_Date)
           }
 
    func pickUpDate(_ textField : UITextField)
           {
               
               // DatePicker
               self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
               self.datePicker.backgroundColor = UIColor.white
               self.datePicker.datePickerMode = UIDatePicker.Mode.date
               textField.inputView = self.datePicker
               
               // ToolBar
               let toolBar = UIToolbar()
               toolBar.barStyle = .default
               toolBar.isTranslucent = true
               toolBar.tintColor = .red
               toolBar.sizeToFit()
               
               // Adding Button ToolBar
            let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(AddNoteVC.doneClick))
               let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
               let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(AddNoteVC.cancelClick))
               toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
               toolBar.isUserInteractionEnabled = true
               textField.inputAccessoryView = toolBar
               
           }
    
    @IBAction func update(_ sender: UIBarButtonItem) {
        note.title = txttitle.text!
        
                         note.desc = txtDesc.text!
        note.dateSelect = datePicker.date
                         note.folder = self.folder
          
                     do {
                         try context.save()
                         listArray.append(note);
                         let alertBox = UIAlertController(title: "Alert", message: "Data updated Successfully", preferredStyle: .alert)
                         alertBox.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                             self.navigationController?.popViewController(animated: true)

                            // self.datecompare()
                         }))
                         self.present(alertBox, animated: true, completion: nil)
                     }
        catch {

                         let alertBox = UIAlertController(title: "Error", message: "Error", preferredStyle: .alert)
                         alertBox.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                         self.present(alertBox, animated: true, completion: nil)
                     }
                     if (userIsEditing == false) {
                         self.navigationController?.popViewController(animated: true)
                     }
    }
    
     @objc func doneClick()
            {
                let dateFormatter1 = DateFormatter()
                dateFormatter1.dateStyle = .medium
                dateFormatter1.timeStyle = .none
                textField_Date.text = dateFormatter1.string(from: datePicker.date)
                textField_Date.resignFirstResponder()
            }
    @objc func cancelClick()
            {
                textField_Date.resignFirstResponder()
            }
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
        {
            (result : UIAlertAction) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
        })
        present(ac, animated: true)
    }
    
    @IBAction func btnSave(_ sender: Any) {
 
        if (userIsEditing == true) {
            note.desc = txtDesc.text!
            note.dateSelect=datePicker.date
        }
        else {
            
            self.note = Notes(context:context)
          note.setValue(Date().currentTimeMillis(), forKey:"created")
            if (txttitle.text!.isEmpty) {
                note.title = "No Title"
            }
            else{
                note.title = txttitle.text!
                   savebtn.isEnabled=false
                   
            }
            note.desc = txtDesc.text!
            
            note.folder = self.folder
             note.dateSelect=datePicker.date
        }
        
        do {
            try context.save()
            listArray.append(note);
            let alertBox = UIAlertController(title: "Alert", message: "Data Save Successfully", preferredStyle: .alert)
            alertBox.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alertBox, animated: true, completion: nil)
        }
        catch {
           
            let alertBox = UIAlertController(title: "Error", message: "Error", preferredStyle: .alert)
            alertBox.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertBox, animated: true, completion: nil)
        }
        if (userIsEditing == false) {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
    
    
    func showDialog() {
        let alert = UIAlertController(title: "Note Image", message: "Please add title of  note.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
   
    

    

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    

    
    
}
extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
