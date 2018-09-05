//
//  ExploreCoursesCollectionHeaderView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 04.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension ExploreCoursesCollectionHeaderView {
    struct Appearance {
        let summaryPlaceholderCornerRadius: CGFloat = 8
        let summaryPlaceholderHeight: CGFloat = 104
        let viewsSpacing: CGFloat = 20
    }
}

final class ExploreCoursesCollectionHeaderView: UIView {
    let appearance: Appearance

    private lazy var headerView: ExploreBlockHeaderView = {
        let view = ExploreBlockHeaderView(frame: .zero)
        return view
    }()

    private lazy var summaryPlaceholder: GradientCoursesPlaceholderView = {
        let view = GradientCoursesPlaceholderView(frame: .zero, color: .pink)
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.summaryPlaceholderCornerRadius
        return view
    }()

    var titleText: String? {
        didSet {
            self.headerView.titleText = self.titleText
        }
    }

    var summaryText: String? {
        didSet {
            self.headerView.summaryText = self.summaryText
        }
    }

    var descriptionText: String? {
        didSet {
            self.summaryPlaceholder.titleText = NSAttributedString(
                string: self.descriptionText ?? ""
            )
        }
    }

    init(frame: CGRect, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ExploreCoursesCollectionHeaderView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.summaryPlaceholder)
        self.addSubview(self.headerView)
    }

    func makeConstraints() {
        self.summaryPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        self.summaryPlaceholder.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.summaryPlaceholderHeight)
        }

        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top
                .equalTo(self.summaryPlaceholder.snp.bottom)
                .offset(self.appearance.viewsSpacing)
        }
    }
}
