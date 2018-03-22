//
//  TVAlertView.swift
//  StepikTV
//
//  Created by Александр Пономарев on 30.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class TVAlertView: BlurredView {

    enum AlertType {
        case action
        case notification
    }

    private var alertType: AlertType = .notification

    private var colorStyle: UIColor = UIColor.gray

    private var actionButton: TVTextButton?
    private var titleLabel: UILabel!

    private var action: (() -> Void)?

    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!

    private var yConstraint: NSLayoutConstraint!

    required init(frame: CGRect, style: UIBlurEffectStyle, color: UIColor = .gray) {
        super.init(frame: frame, style: style)

        colorStyle = color
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setup(title: String) {
        alertType = .notification

        // init ui
        addSubviews()
        setupLayouts()

        // set properties
        titleLabel.text = title
    }

    func setup(title: String, buttonTitle: String, action: @escaping () -> Void) {
        alertType = .action

        // init ui
        addSubviews()
        setupLayouts()

        // set properties
        titleLabel.text = title
        self.action = action

        actionButton?.setTitle(buttonTitle, for: .normal)
        actionButton?.addTarget(self, action: #selector(action(_:)), for: UIControlEvents.primaryActionTriggered)
    }

    private func addSubviews() {
        if alertType == .action {
            actionButton = TVTextButton()
            actionButton!.contentEdgeInsets = UIEdgeInsets(top: 0, left: 70.0, bottom: 0, right: 70.0)

            self.addSubview(actionButton!)
        }

        titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.systemFont(ofSize: 38.0, weight: .medium)
        titleLabel.textColor = colorStyle
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center

        self.addSubview(titleLabel)
    }

    private func setupLayouts() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40).isActive = true

        guard let actionButton = actionButton else {
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true

            return
        }

        titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -40).isActive = true

        actionButton.translatesAutoresizingMaskIntoConstraints = false

        actionButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        actionButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 42.0).isActive = true
        actionButton.heightAnchor.constraint(equalToConstant: 66).isActive = true

        self.layoutIfNeeded()
    }

    @objc private func action(_ sender: UIButton) {
        action?()
    }

}
