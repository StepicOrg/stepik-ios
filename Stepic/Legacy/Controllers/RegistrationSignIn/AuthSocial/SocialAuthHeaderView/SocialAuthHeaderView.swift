//
//  SocialAuthHeaderView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

final class SocialAuthHeaderView: UICollectionReusableView {
    static let reuseId = "socialAuthHeaderView"

    @IBOutlet weak var titleLabel: StepikLabel!

    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel.textColor = .stepikPrimaryText
    }

    func setup(title: String) {
        self.titleLabel.setTextWithHTMLString(title)
    }
}
