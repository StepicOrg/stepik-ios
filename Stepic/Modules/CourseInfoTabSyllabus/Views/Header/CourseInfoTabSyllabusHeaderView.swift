//
//  CourseInfoTabSyllabusHeaderView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15/11/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoTabSyllabusHeaderView {
    struct Appearance {
        let buttonSpacing: CGFloat = 14.0

        let buttonTintColor = UIColor.mainDark
        let buttonFont = UIFont.systemFont(ofSize: 14, weight: .light)
        let buttonImageInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 4)
        let buttonTitleInsets = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 0)
        let buttonImageSize = CGSize(width: 15, height: 15)

        let insets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)

        let separatorColor = UIColor(hex: 0xcccccc)
        let separatorHeight: CGFloat = 1
    }
}

final class CourseInfoTabSyllabusHeaderView: UIView {
    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.buttonSpacing
        return stackView
    }()

    private lazy var calendarButton: ImageButton = {
        let button = ImageButton()
        button.image = UIImage(named: "course-info-syllabus-calendar")?.withRenderingMode(.alwaysTemplate)
        button.tintColor = self.appearance.buttonTintColor
        button.title = NSLocalizedString("SyllabusDeadlinesButton", comment: "")
        button.font = self.appearance.buttonFont
        button.imageInsets = self.appearance.buttonImageInsets
        button.titleInsets = self.appearance.buttonTitleInsets
        button.imageSize = self.appearance.buttonImageSize
        button.isHidden = true
        button.addTarget(
            self,
            action: #selector(self.onCalendarButtonClicked),
            for: .touchUpInside
        )
        return button
    }()

    private lazy var downloadAllButton: UIControl = {
        let button = ImageButton()
        button.image = UIImage(named: "course-info-syllabus-download-all")?.withRenderingMode(.alwaysTemplate)
        button.tintColor = self.appearance.buttonTintColor
        button.title = NSLocalizedString("SyllabusDownloadAll", comment: "")
        button.font = self.appearance.buttonFont
        button.imageInsets = self.appearance.buttonImageInsets
        button.titleInsets = self.appearance.buttonTitleInsets
        button.imageSize = self.appearance.buttonImageSize
        button.isEnabled = false
        button.addTarget(
            self,
            action: #selector(self.onDownloadAllButtonClicked),
            for: .touchUpInside
        )
        return button
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
    }()

    var shouldShowCalendarButton: Bool = false {
        didSet {
            self.calendarButton.isHidden = !self.shouldShowCalendarButton
        }
    }

    var isDownloadAllButtonEnabled: Bool = true {
        didSet {
            self.downloadAllButton.isEnabled = self.isDownloadAllButtonEnabled
        }
    }

    // Reference to tooltip-anchor view
    var deadlinesButtonTooltipAnchorView: UIView {
        return self.calendarButton.titleContentView
    }

    var onCalendarButtonClick: (() -> Void)?
    var onDownloadAllButtonClick: (() -> Void)?

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func onCalendarButtonClicked() {
        self.onCalendarButtonClick?()
    }

    @objc
    private func onDownloadAllButtonClicked() {
        self.onDownloadAllButtonClick?()
    }
}

extension CourseInfoTabSyllabusHeaderView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)
        self.addSubview(self.separatorView)

        self.stackView.addArrangedSubview(self.calendarButton)
        self.stackView.addArrangedSubview(self.downloadAllButton)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing
                .lessThanOrEqualToSuperview()
                .offset(-self.appearance.insets.right)
                .priority(999)
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.top.equalTo(self.stackView.snp.bottom).offset(self.appearance.insets.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(self.appearance.separatorHeight)
        }
    }
}
