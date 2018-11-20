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
        let buttonFont = UIFont.systemFont(ofSize: 13, weight: .light)
        let buttonImageInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 4)
        let buttonTitleInsets = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 0)
        let buttonImageSize = CGSize(width: 15, height: 15)

        let insets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
    }
}

final class CourseInfoTabSyllabusHeaderView: UIView {
    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.buttonSpacing
        stackView.distribution = .fillProportionally
        return stackView
    }()

    private lazy var calendarButton: UIControl = {
        let button = ImageButton()
        button.image = UIImage(named: "course-info-syllabus-calendar")?.withRenderingMode(.alwaysTemplate)
        button.tintColor = self.appearance.buttonTintColor
        button.title = "Расписание"
        button.font = self.appearance.buttonFont
        button.imageInsets = self.appearance.buttonImageInsets
        button.titleInsets = self.appearance.buttonTitleInsets
        button.imageSize = self.appearance.buttonImageSize
        return button
    }()

    private lazy var downloadAllButton: UIControl = {
        let button = ImageButton()
        button.image = UIImage(named: "course-info-syllabus-download-all")?.withRenderingMode(.alwaysTemplate)
        button.tintColor = self.appearance.buttonTintColor
        button.title = "Загрузить всё"
        button.font = self.appearance.buttonFont
        button.imageInsets = self.appearance.buttonImageInsets
        button.titleInsets = self.appearance.buttonTitleInsets
        button.imageSize = self.appearance.buttonImageSize
        return button
    }()

    private lazy var filterButton: UIControl = {
        let button = ImageButton()
        button.image = UIImage(named: "course-info-syllabus-filter")?.withRenderingMode(.alwaysTemplate)
        button.tintColor = self.appearance.buttonTintColor
        button.title = "Фильтр"
        button.font = self.appearance.buttonFont
        button.imageInsets = self.appearance.buttonImageInsets
        button.titleInsets = self.appearance.buttonTitleInsets
        button.imageSize = self.appearance.buttonImageSize
        return button
    }()

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
}

extension CourseInfoTabSyllabusHeaderView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {

    }

    func addSubviews() {
        self.addSubview(self.stackView)

        self.stackView.addArrangedSubview(self.calendarButton)
        self.stackView.addArrangedSubview(self.downloadAllButton)
        self.stackView.addArrangedSubview(self.filterButton)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
        }
    }
}
