//
//  SocialAuthHeaderView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class SocialAuthHeaderView: UICollectionReusableView {
    static let reuseId = "socialAuthHeaderView"

    @IBOutlet weak var titleLabel: StepikLabel!

    func setup(title: String) {
        titleLabel.setTextWithHTMLString(title)
    }
}
