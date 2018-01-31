//
//  TVAlertView.swift
//  StepikTV
//
//  Created by Александр Пономарев on 30.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class TVAlertView: BlurredView {

    private var colorStyle: UIColor = UIColor.white

    private var actionButton: StandardButton!
    private var titleLabel: UILabel!

    private var action: (() -> Void)!

    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)

        colorStyle = color
        addSubviews()
        setupLayout()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
        setupLayout()
    }

    func setup(title: String) {
        titleLabel.text = title

        actionButton.isHidden = true
    }

    func setup(title: String, buttonTitle: String, action: @escaping () -> Void) {
        self.action = action

        titleLabel.text = title

        actionButton.setTitle(buttonTitle, for: .normal)
        actionButton.addTarget(self, action: #selector(action(_:)), for: UIControlEvents.primaryActionTriggered)

        actionButton.isHidden = false
    }

    private func addSubviews() {
        actionButton = StandardButton()
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 70.0, bottom: 0, right: 70.0)

        titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.systemFont(ofSize: 38.0, weight: UIFontWeightMedium)
        titleLabel.textColor = colorStyle

        self.addSubview(actionButton)
        self.addSubview(titleLabel)
    }

    private func setupLayout() {
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        actionButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        actionButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 62.0).isActive = true

        actionButton.heightAnchor.constraint(equalToConstant: 66).isActive = true

        titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -70).isActive = true
    }

    @objc private func action(_ sender: UIButton) {
        action()
    }

}
