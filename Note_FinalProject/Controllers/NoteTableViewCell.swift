//
//  NoteViewController.swift
//  Note_FinalProject
//
//  Created by Harkirat Singh on 2020-06-21.
//  Copyright © 2020 Harkirat Singh. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {


       @IBOutlet weak var titleLbl: UILabel!
    
      @IBOutlet weak var dateLbl: UILabel!
       override func awakeFromNib() {
           super.awakeFromNib()
           // Initialization code
       }

       override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)

          
       }

   }

