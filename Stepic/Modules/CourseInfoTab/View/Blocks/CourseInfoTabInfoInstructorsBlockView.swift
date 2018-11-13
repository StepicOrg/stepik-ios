//
//  CourseInfoInstructorBlockView.swift
//  Stepic
//
//  Created by Ivan Magda on 11/1/18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoTabInfoInstructorsBlockView {
    struct Appearance {
        let headerViewInsets = UIEdgeInsets(top: 37, left: 20, bottom: 0, right: 47)

        let stackViewInsets = UIEdgeInsets(top: 20, left: 47, bottom: 0, right: 47)
        let stackViewSpacing: CGFloat = 18
    }
}

final class CourseInfoTabInfoInstructorsBlockView: UIView {
    private let appearance: Appearance

    private lazy var headerView = CourseInfoTabInfoBlockView()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
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

    func configure(viewModel: CourseInfoTabInfoInstructorsBlockViewModel) {
        self.headerView.configure(viewModel: viewModel)

        if !self.stackView.arrangedSubviews.isEmpty {
            self.stackView.removeAllArrangedSubviews()
        }

        viewModel.instructors.forEach { instructor in
            let view = CourseInfoTabInfoInstructorView()
            view.configure(viewModel: instructor)
            self.stackView.addArrangedSubview(view)
        }
    }
}

extension CourseInfoTabInfoInstructorsBlockView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.headerView)
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.headerViewInsets.left)
            make.top.equalToSuperview().offset(self.appearance.headerViewInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.headerViewInsets.right)
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.stackViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.stackViewInsets.right)
            make.bottom.equalToSuperview().offset(self.appearance.stackViewInsets.bottom)
            make.top
                .equalTo(self.headerView.snp.bottom)
                .offset(self.appearance.stackViewInsets.top)
        }
    }
}
