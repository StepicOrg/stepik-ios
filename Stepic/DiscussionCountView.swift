//
//  DiscussionCountView.swift
//  Stepic
//
//  Created by Alexander Karpov on 28.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class DiscussionCountView: NibInitializableView {

    @IBOutlet weak var showCommentsLabel: StepikLabel!
    var showCommentsHandler: (() -> Void)?

    override var nibName: String {
        return "DiscussionCountView"
    }

    var commentsCount: Int = 0 {
        didSet {
            showCommentsLabel.text = "\(NSLocalizedString("ShowComments", comment: "")) (\(commentsCount))"
        }
    }

    override func setupSubviews() {
        view.backgroundColor = UIColor.mainLight
    }

    @IBAction func showCommentsPressed(_ sender: AnyObject) {
        showCommentsHandler?()
    }
}
