//
//  ChoiceCustomTextField.swift
//  StepikTV
//
//  Created by Александр Пономарев on 09.11.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class TaskChoiceCustomButton: UIButton {

    static func createButtonsStack(with array: [String]) -> [TaskChoiceCustomButton] {
        var buttons = [TaskChoiceCustomButton]()
        for choice in array {
            let button = TaskChoiceCustomButton(choiceText: choice)
            buttons.append(button)
        }
        return buttons
    }

    private var choiceText: String
    var status: ChoiceStatus = .NotSelected

    init(choiceText: String) {
        self.choiceText = choiceText

        // Construct Button
        super.init(frame: CGRect.zero)

        self.setTitle(choiceText, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: UIFontWeightMedium)
        self.titleLabel?.numberOfLines = 1

        self.contentHorizontalAlignment = .left

        self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 80)

        self.setImage(ChoiceStatus.Selected.icon, for: .normal)
        self.setImage(ChoiceStatus.NotSelected.icon, for: .focused)
        self.setImage(ChoiceStatus.NotSelected.icon, for: .highlighted)

        self.sizeToFit()

        self.widthAnchor.constraint(equalToConstant: self.frame.width).isActive = true
        self.heightAnchor.constraint(equalToConstant: self.frame.height).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeToFit() {
        super.sizeToFit()

        var newBounds = self.bounds
            newBounds.size.width = newBounds.width + self.titleEdgeInsets.left

        self.bounds = newBounds
    }

    override var canBecomeFocused: Bool {
        return true
    }
}
