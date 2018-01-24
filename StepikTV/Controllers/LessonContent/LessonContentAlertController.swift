//
//  LessonContentAlertController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 12.11.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

enum ChoiceType {
    case Multiple, Single
}

class LessonContentAlertController: UIAlertController {

    private(set) var question: String!
    private(set) var choices: [String]?
    private(set) var type: ChoiceType?

    private var contentView: UIView!
    private var titleLabel: UILabel!
    private var answerTextField: UITextField?
    private var buttonsStack: UIStackView?
    private var leaveButton: UIButton!

    private var choicesButtons: [TaskChoiceCustomButton]!

    let contentWidth: CGFloat = 900

    func generateTextTaskContent(question: String) {
        self.question = question

        contentView = UIView(frame: CGRect(x: 0, y: 0, width: self.contentWidth, height: 0))
        titleLabel = initTitleLabel(with: question)
        answerTextField = initTextField()
        leaveButton = initButton(with: "Отправить", action: #selector(LessonContentAlertController.leaveAlert(_:)))

        arrangeViews(with: answerTextField!)
    }

    func generateChoiceTaskContent(question: String, choices: [String], type: ChoiceType = .Single) {
        self.question = question
        self.choices = choices
        self.type = type

        contentView = UIView(frame: CGRect(x: 0, y: 0, width: self.contentWidth, height: 0))
        titleLabel = initTitleLabel(with: question)
        choicesButtons = TaskChoiceCustomButton.createButtonsStack(with: choices)
        buttonsStack = UIStackView(arrangedSubviews: choicesButtons)
        leaveButton = initButton(with: "Отправить", action: #selector(LessonContentAlertController.leaveAlert(_:)))

        arrangeViews(with: buttonsStack!)
    }

    private func arrangeViews(with changableView: UIView) {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        leaveButton.translatesAutoresizingMaskIntoConstraints = false
        changableView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(titleLabel)
        contentView.addSubview(leaveButton)
        contentView.addSubview(changableView)
        view.addSubview(contentView)

        // Title label set layouts
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true

        // Main iteractional view set layouts
        changableView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        changableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 70).isActive = true

        // Leave button set layouts
        leaveButton.topAnchor.constraint(equalTo: changableView.bottomAnchor, constant: 100).isActive = true
        leaveButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true

        // Content view set layouts
        let screenWidth = UIScreen.main.bounds.width
        contentView.widthAnchor.constraint(equalToConstant: screenWidth - 350).isActive = true

        // Force layout subviews to adopt contentView's size
        //contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
        adoptContentViewHeight()

        contentView.heightAnchor.constraint(equalToConstant: contentView.bounds.height).isActive = true
        contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    private func initButton(with title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)

        button.setTitle("Отправить", for: .normal)
        button.addTarget(self, action: action, for: .primaryActionTriggered)

        button.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 86.0).isActive = true

        return button
    }

    private func initTitleLabel(with question: String) -> UILabel {
        let label = UILabel(frame: CGRect.zero)

        label.text = question
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 40, weight: UIFontWeightMedium)

        return label
    }

    private func initTextField() -> UITextField {
        let textField = UITextField(frame: CGRect.zero)

        textField.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        textField.font = UIFont.systemFont(ofSize: 47, weight: UIFontWeightRegular)
        textField.textColor = UIColor.white
        textField.placeholder = "Ответ"

        // Keyboard settings
        textField.keyboardAppearance = .dark

        textField.widthAnchor.constraint(equalToConstant: 809.0).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 79.0).isActive = true

        return textField
    }

    private func initButtonStack(with buttons: [TaskChoiceCustomButton]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: buttons)

        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.alignment = .leading
        stack.spacing = 20

        return stack
    }

    private func adoptContentViewHeight() {
        var newContentBounds = contentView.bounds
        newContentBounds.size.height = leaveButton.frame.origin.y + leaveButton.frame.height

        contentView.bounds = newContentBounds
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard presses.first!.type == UIPressType.menu else {
            super.pressesBegan(presses, with: event)
            return
        }

        leaveAlert(self)
    }

    @objc func leaveAlert(_: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
