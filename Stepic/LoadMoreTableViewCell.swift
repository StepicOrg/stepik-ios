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
    
    weak var sectionUpdateDelegate : DiscussionUpdateDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        tapG = UITapGestureRecognizer(target: self, action: #selector(LoadMoreTableViewCell.didTap(_:)))
        tapG.numberOfTapsRequired = 1
        self.contentView.addGestureRecognizer(tapG)
        showMoreActivityIndicator.hidden = true
    }

    var showMorePressedHandler : (Int->Void)?
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
    
    func didTap(recognizer: UITapGestureRecognizer) {
        if !isUpdating {
            setHighlighted(true, animated: true)
            showMoreLabel.hidden = true
            showMoreActivityIndicator.hidden = false
            isUpdating = true
            sectionUpdateDelegate?.update(section: tag, completion: {
                [weak self] in
                self?.isUpdating = false
            })
            setHighlighted(false, animated: true)
        }
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
