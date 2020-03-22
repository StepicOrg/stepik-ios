//
//  StepReversedCardView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

final class StepReversedCardView: UIView {
    lazy var whiteView: UIView = {
        let view = UIView(frame: self.bounds)
        self.addSubview(view)
        view.backgroundColor = UIColor(patternImage: Images.patterns.gray)
        return view
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        if #available(iOS 13.0, *), self.traitCollection.userInterfaceStyle == .dark {
            self.backgroundColor = .stepikSecondaryBackground
        } else {
            self.backgroundColor = .stepikBackground
        }

        self.layer.cornerRadius = 12
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.stepikOpaqueSeparator.cgColor

        self.whiteView.frame = self.bounds
    }
}
