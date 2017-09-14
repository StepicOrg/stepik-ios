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

    var isRefreshing: Bool = true {
        didSet(value) {
            if value {
                activityIndicator.isHidden = false
                refreshButton.isHidden = true
                activityIndicator.startAnimating()
                refresh?()
            } else {
                activityIndicator.isHidden = true
                refreshButton.isHidden = false
                activityIndicator.stopAnimating()
            }
        }
    }

    @IBAction func refreshPressed(_ sender: UIButton) {
        isRefreshing = true
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.color = UIColor.mainDark
        // Initialization code
    }

    fileprivate var refresh : (() -> Void)?

    func initWithMessage(_ message: String, isRefreshing: Bool, refreshAction : @escaping () -> Void) {
        refresh = refreshAction
        self.isRefreshing = isRefreshing
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
