//
//  LoadMoreTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 13.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

final class LoadMoreTableViewCell: UITableViewCell, Reusable, NibLoadable {
    @IBOutlet weak var showMoreLabel: StepikLabel!
    @IBOutlet weak var showMoreActivityIndicator: UIActivityIndicatorView!

    var tapG: UITapGestureRecognizer!
    var section: Int?

    override func awakeFromNib() {
        super.awakeFromNib()
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
    }

    override func prepareForReuse() {
        showMoreLabel.isHidden = false
    }
}
