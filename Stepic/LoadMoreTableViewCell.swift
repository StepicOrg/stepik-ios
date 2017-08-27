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

    var tapG: UITapGestureRecognizer!
    var section: Int?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        showMoreActivityIndicator.isHidden = true
    }

    var isUpdating: Bool = false {
        didSet {
            if isUpdating {
                showMoreLabel.isHidden = true
                showMoreActivityIndicator.isHidden = false
                showMoreActivityIndicator.startAnimating()
            } else {
                showMoreActivityIndicator.stopAnimating()
                showMoreActivityIndicator.isHidden = true
                showMoreLabel.isHidden = false
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    override func prepareForReuse() {
//        showMoreActivityIndicator.hidden = true
        showMoreLabel.isHidden = false
    }

}
