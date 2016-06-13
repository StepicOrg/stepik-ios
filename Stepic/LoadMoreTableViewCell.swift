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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        tapG = UITapGestureRecognizer(target: self, action: #selector(LoadMoreTableViewCell.didTap(_:)))
        tapG.numberOfTapsRequired = 1
        self.contentView.addGestureRecognizer(tapG)
    }

    var showMorePressedHandler : (Int->Void)?
    
    func didTap(recognizer: UITapGestureRecognizer) {
        setHighlighted(true, animated: true)
        showMoreLabel.hidden = true
        showMoreActivityIndicator.hidden = false
        showMoreActivityIndicator.startAnimating()
        showMorePressedHandler?(tag)
        setHighlighted(false, animated: true)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        showMoreActivityIndicator.hidden = true
        showMoreLabel.hidden = false
    }
    
}
