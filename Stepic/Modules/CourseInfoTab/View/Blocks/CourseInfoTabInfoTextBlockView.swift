//
//  CourseInfoTabInfoTextBlockView.swift
//  Stepic
//
//  Created by Ivan Magda on 11/1/18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoTabInfoTextBlockView {
    struct Appearance {
        var headerViewInsets = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 47)

        var messageLabelInsets = UIEdgeInsets(top: 20, left: 47, bottom: 0, right: 47)
        let messageLabelFont = UIFont.systemFont(ofSize: 12, weight: .light)
        let messageLabelTextColor = UIColor(hex: 0x535366)
    }
}

final class CourseInfoTabInfoTextBlockView: UIView {
    private let appearance: Appearance

    private lazy var headerView = CourseInfoTabInfoBlockView()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = self.appearance.messageLabelFont
        label.textColor = self.appearance.messageLabelTextColor
        return label
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        viewModel: CourseInfoTabInfoTextBlockViewModel
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()

        self.configure(with: viewModel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(with viewModel: CourseInfoTabInfoTextBlockViewModel) {
        self.headerView.configure(with: viewModel)
        self.messageLabel.text = viewModel.message
    }
}

extension CourseInfoTabInfoTextBlockView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.headerView)
        self.addSubview(self.messageLabel)
    }

    func makeConstraints() {
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.headerViewInsets.left)
            make.top.equalToSuperview().offset(self.appearance.headerViewInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.headerViewInsets.right)
        }

        self.messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.messageLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.messageLabelInsets.left)
            make.bottom.equalToSuperview().offset(self.appearance.messageLabelInsets.bottom)
            make.top.equalTo(self.headerView.snp.bottom).offset(self.appearance.messageLabelInsets.top)
            make.trailing.equalTo(self.headerView)
        }
    }
}
