//
//  CourseListEmptyPlaceholder.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class CourseListEmptyPlaceholder: NibInitializableView {

    @IBOutlet weak var textLabel: StepikLabel!

    @IBOutlet weak var contentView: UIView!

    var text: String = "" {
        didSet {
            textLabel.setTextWithHTMLString(text)
            if textLabel.numberOfVisibleLines == 1 {
                textLabel.textAlignment = .center
            } else {
                textLabel.textAlignment = .natural
            }
        }
    }

    var onTap: (() -> Void)?

    override var nibName: String {
        return "CourseListEmptyPlaceholder"
    }

    override func setupSubviews() {
        textLabel.colorMode = .light
        let tapG = UITapGestureRecognizer(target: self, action: #selector(CourseListEmptyPlaceholder.didTap(touch:)))
        contentView.addGestureRecognizer(tapG)
        contentView.setRoundedCorners(cornerRadius: 8)
    }

    func didTap(touch: UITapGestureRecognizer) {
        onTap?()
    }
}
