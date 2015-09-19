//
//  RefreshTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 19.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit

class RefreshTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initWithMessage(message : String) {
        activityIndicator.startAnimating()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
