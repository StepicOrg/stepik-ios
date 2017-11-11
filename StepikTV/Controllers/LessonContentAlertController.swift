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
    private(set) var choices: [String]!
    private(set) var type: ChoiceType!

    private var contentView: UIView!
    private var titleLabel: UILabel!
    private var buttonsStack: UIStackView!
    private var leaveButton: UIButton!

    private var choicesButtons: [TaskChoiceCustomButton]!

    let contentWidth: CGFloat = 900

    func generateTaskContent(question: String, choices: [String], type: ChoiceType = .Single) {
        self.question = question
        self.choices = choices
        self.type = type

        contentView = UIView(frame: CGRect(x: 0, y: 0, width: self.contentWidth, height: 0))
        titleLabel = initTitleLabel(with: question)
        choicesButtons = TaskChoiceCustomButton.createButtonsStack(with: choices)
        buttonsStack = UIStackView(arrangedSubviews: choicesButtons)
        leaveButton = initButton(with: "Отправить", action: #selector(LessonContentAlertController.leaveAlert(_:)))

        arrangeViews()
    }

    private func arrangeViews() {
        buttonsStack.axis = .vertical
        buttonsStack.distribution = .equalSpacing
        buttonsStack.alignment = .leading
        buttonsStack.spacing = 20

        contentView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        leaveButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(titleLabel)
        contentView.addSubview(buttonsStack)
        contentView.addSubview(leaveButton)
        view.addSubview(contentView)

        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true

        buttonsStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        buttonsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 70).isActive = true

        leaveButton.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        leaveButton.heightAnchor.constraint(equalToConstant: 86.0).isActive = true
        leaveButton.topAnchor.constraint(equalTo: buttonsStack.bottomAnchor, constant: 100).isActive = true
        leaveButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true

        // Force layout subviews to adopt contentView's size
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()

        adoptContentViewHeight()

        contentView.widthAnchor.constraint(equalToConstant: contentWidth).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: contentView.bounds.height).isActive = true

        contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    private func initButton(with title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)

        button.setTitle("Отправить", for: .normal)
        button.addTarget(self, action: action, for: .primaryActionTriggered)

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

    private func adoptContentViewHeight() {
        var newContentBounds = contentView.bounds
        newContentBounds.size.height = leaveButton.frame.origin.y + leaveButton.frame.height

        contentView.bounds = newContentBounds
    }

    @objc func leaveAlert(_: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
