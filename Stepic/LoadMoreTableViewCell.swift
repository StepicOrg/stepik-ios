//
//  LoadMoreTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 13.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class LoadMoreTableViewCell: UITableViewCell {

    @IBOutlet weak var showMoreLabel: UILabel!
    @IBOutlet weak var showMoreActivityIndicator: UIActivityIndicatorView!
    
    var tapG : UITapGestureRecognizer!
    var section: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        showMoreActivityIndicator.hidden = true
    }

    var isUpdating: Bool = false {
        didSet {
            if isUpdating {
                showMoreLabel.hidden = true
                showMoreActivityIndicator.hidden = false
                showMoreActivityIndicator.startAnimating()
            } else {
                showMoreActivityIndicator.stopAnimating()
                showMoreActivityIndicator.hidden = true
                showMoreLabel.hidden = false
            }
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
//        showMoreActivityIndicator.hidden = true
        showMoreLabel.hidden = false
    }
    
}
