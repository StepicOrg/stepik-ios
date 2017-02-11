//
//  FillBlanksInputTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 11.02.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

//Preferrable height equals 44

import UIKit

class FillBlanksInputTableViewCell: UITableViewCell {

    @IBOutlet weak var inputTextField: UITextField!
    
    let placeholderText = "Enter your answer" 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inputTextField.placeholder = placeholderText
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    class var defaultHeight : CGFloat = 44
    
}
