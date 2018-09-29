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
        let view = ExploreBlockHeaderView(
            frame: .zero,
            appearance: CourseListColorMode.light.exploreBlockHeaderViewAppearance
        )
        // REVIEW: l10n
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

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addBlockView(_ view: UIView) {
        self.contentStackView.addArrangedSubview(view)
    }

    func removeAllBlocks() {
        self.contentStackView.removeAllArrangedSubviews()
    }
}

extension CourseListsCollectionView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.headerView)
        self.addSubview(self.contentStackView)
    }

    func makeConstraints() {
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(Appearance.headerViewInsets.left)
            make.trailing.equalToSuperview().offset(-Appearance.headerViewInsets.right)
        }

        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentStackView.snp.makeConstraints { make in
            make.top.equalTo(self.headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
    }
}
