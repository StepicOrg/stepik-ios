//
// CourseInfoTabInfoTextBlockView.swift
// stepik-ios
//
//  Created by Ivan Magda on 11/1/18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoTabInfoTextBlockView {
    struct Appearance {
        var headerViewInsets = UIEdgeInsets(top: 40, left: 20, bottom: 0, right: 47)

        let messageLabelInsets = UIEdgeInsets(top: 20, left: 47, bottom: 0, right: 47)
        let messageLabelFont = UIFont.systemFont(ofSize: 12, weight: .light)
        let messageLabelTextColor = UIColor.mainDark
    }
}

final class CourseInfoTabInfoTextBlockView: UIView {
    var message: String? {
        didSet {
            self.messageLabel.text = self.message
        }
    }

    private let appearance: Appearance

    lazy var headerView = CourseInfoTabInfoHeaderBlockView()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = self.appearance.messageLabelFont
        label.textColor = self.appearance.messageLabelTextColor
        return label
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            make.trailing.equalTo(self.headerView)
            make.top
                .equalTo(self.headerView.snp.bottom)
                .offset(self.appearance.messageLabelInsets.top)
        }
    }
}
