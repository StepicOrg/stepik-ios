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
    @IBOutlet weak var refreshButton: UIButton!
    
    var isRefreshing : Bool = true {
        didSet(value) {
            if value {
                activityIndicator.hidden = false
                refreshButton.hidden = true
                activityIndicator.startAnimating()
                refresh?()
            } else {
                activityIndicator.hidden = true
                refreshButton.hidden = false
                activityIndicator.stopAnimating()
            }
        }
    }
    
    @IBAction func refreshPressed(sender: UIButton) {
        isRefreshing = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private var refresh : (Void->Void)?
    
    func initWithMessage(message : String, isRefreshing: Bool, refreshAction : Void->Void) {
        refresh = refreshAction
        self.isRefreshing = isRefreshing
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
