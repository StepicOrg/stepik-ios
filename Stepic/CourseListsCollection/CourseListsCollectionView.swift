//
//  CourseListsCollectionView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 03.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

final class CourseListsCollectionView: UIView {
    enum Appearance {
        static let headerViewInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }

    private lazy var headerView: ExploreBlockHeaderView = {
        let view = ExploreBlockHeaderView(frame: .zero)
        view.titleText = "Recommendations"
        view.summaryText = "Check out Stepik Categories Lists that matching your interests"
        view.shouldShowShowAllButton = false
        return view
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    private let contentView: UIView

    override var intrinsicContentSize: CGSize {
        let headerViewHeight = self.headerView.intrinsicContentSize.height
        let headerViewPadding = Appearance.headerViewInsets.top
            + Appearance.headerViewInsets.bottom
        let contentStackViewHeight = self.contentStackView
            .systemLayoutSizeFitting(UILayoutFittingCompressedSize)
            .height
        return CGSize(
            width: UIViewNoIntrinsicMetric,
            height: headerViewHeight + headerViewPadding + contentStackViewHeight
        )
    }

    init(frame: CGRect, contentView: UIView) {
        self.contentView = contentView
        super.init(frame: frame)
        self.backgroundColor = .white
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initialize() {
        self.addSubview(self.headerView)
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(Appearance.headerViewInsets.left)
            make.trailing.equalToSuperview().offset(-Appearance.headerViewInsets.right)
        }

        self.addSubview(self.contentStackView)
        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentStackView.snp.makeConstraints { make in
            make.top.equalTo(self.headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        let view = ExploreCoursesCollectionHeaderView(frame: .zero)
        view.titleText = "Mobile friendly"
        view.summaryText = "8 courses"
        view.descriptionText = "Welcome to our Mobile Friendly List.\nIt’s fully completed in the App!"
        let container = ExploreBlockContainerView(
            frame: .zero,
            headerView: view,
            contentView: self.contentView,
            shouldShowSeparator: false
        )

        self.contentStackView.addArrangedSubview(container)
    }
}
