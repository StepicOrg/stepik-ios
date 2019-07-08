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

    var isUpdating: Bool = false {
        didSet {
            if self.isUpdating {
                self.showMoreLabel.isHidden = true
                self.showMoreActivityIndicator.isHidden = false
                self.showMoreActivityIndicator.startAnimating()
            } else {
                self.showMoreActivityIndicator.stopAnimating()
                self.showMoreActivityIndicator.isHidden = true
                self.showMoreLabel.isHidden = false
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.showMoreActivityIndicator.isHidden = true
    }

    override func prepareForReuse() {
        self.showMoreLabel.isHidden = false
    }
}
