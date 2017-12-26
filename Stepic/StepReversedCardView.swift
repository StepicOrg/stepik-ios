//
//  StepReversedCardView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class StepReversedCardView: UIView {

    lazy var whiteView: UIView = {
        let view = UIView(frame: self.bounds)
        self.addSubview(view)
        view.backgroundColor = UIColor(patternImage: Images.patterns.gray)

        return view
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundColor = .white
        layer.cornerRadius = 12
        whiteView.frame = bounds
    }
}
