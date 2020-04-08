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

        self.backgroundColor = .dynamic(light: .stepikBackground, dark: .stepikSecondaryBackground)
        self.layer.cornerRadius = 12
        self.whiteView.frame = self.bounds
    }
}
