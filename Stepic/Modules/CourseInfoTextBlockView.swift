//
//  CourseInfoTextBlockView.swift
//  Stepic
//
//  Created by Ivan Magda on 11/1/18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoTextBlockView {
    struct Appearance {
        let headerViewInsets = UIEdgeInsets(top: 12, left: 12, bottom: 0, right: 36)

        let messageLabelInsets = UIEdgeInsets(top: 12, left: 36, bottom: 0, right: 0)
        let messageLabelFont = UIFont.systemFont(ofSize: 12, weight: .light)
        let messageLabelTextColor = UIColor.black
    }
}

final class CourseInfoTextBlockView: UIView {
    private let appearance: Appearance

    private lazy var headerView: CourseInfoBlockView = {
        CourseInfoBlockView(frame: .zero)
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.font = self.appearance.messageLabelFont
        label.textColor = self.appearance.messageLabelTextColor
        return label
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        viewModel: CourseInfoTextBlockViewModel
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

    private func configure(with viewModel: CourseInfoTextBlockViewModel) {
        self.headerView.configure(with: viewModel)
        self.messageLabel.text = viewModel.message
    }
}

extension CourseInfoTextBlockView: ProgrammaticallyInitializableViewProtocol {
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
            make.leading.top.trailing.equalToSuperview().inset(self.appearance.headerViewInsets)
        }

        self.messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.messageLabel.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(self.appearance.messageLabelInsets)
            make.top.equalTo(self.headerView.snp.bottom).offset(self.appearance.messageLabelInsets.top)
            make.trailing.equalTo(self.headerView)
        }
    }
}
