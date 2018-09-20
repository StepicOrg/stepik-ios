//
//  FullscreenCourseListFullscreenCourseListView.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 19/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit
import SnapKit

extension FullscreenCourseListView {
    struct Appearance {
        let headerHeight: CGFloat = 140.0
    }
}

final class FullscreenCourseListView: UIView {
    let appearance: Appearance

    private let contentView: UIView
    private lazy var headerView: GradientCoursesPlaceholderView = {
        let appearance = GradientCoursesPlaceholderView.Appearance(
            titleFont: UIFont.systemFont(ofSize: 20),
            subtitleFont: UIFont.systemFont(ofSize: 16)
        )
        return GradientCoursesPlaceholderView(
            frame: .zero,
            color: .blue,
            appearance: appearance
        )
    }()

    init(
        frame: CGRect,
        contentView: UIView,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.contentView = contentView
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FullscreenCourseListView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white

        guard let contentView = contentView as? CourseListView else {
            fatalError()
        }

        //contentView.
    }

    func addSubviews() {
        self.addSubview(self.contentView)
    }

    func makeConstraints() {
//        self.headerView.translatesAutoresizingMaskIntoConstraints = false
//        self.headerView.snp.makeConstraints { make in
//            //make.width.equalTo(self.snp.width)
//            //make.top.leading.trailing.equalToSuperview()
//            make.height.equalTo(self.appearance.headerHeight)
//        }

        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.snp.makeConstraints { make in
            make.width.equalTo(self.snp.width)
            make.top.leading.bottom.trailing.equalToSuperview()
        }
    }
}

extension FullscreenCourseListView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
}
