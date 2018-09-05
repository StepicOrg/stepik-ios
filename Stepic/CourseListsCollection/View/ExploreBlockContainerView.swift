//
//  ExploreBlockContainerView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 03.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension ExploreBlockContainerView {
    struct Appearance {
        let separatorColor = UIColor(hex: 0x535366, alpha: 0.1)

        let headerViewInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let contentViewInsets = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        let separatorViewInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
}

final class ExploreBlockContainerView: UIView {
    let appearance: Appearance
    private let headerView: UIView
    private let contentView: UIView
    private let shouldShowSeparator: Bool

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
    }()

    init(
        frame: CGRect,
        headerView: UIView,
        contentView: UIView,
        shouldShowSeparator: Bool = false,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.headerView = headerView
        self.contentView = contentView
        self.shouldShowSeparator = shouldShowSeparator
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ExploreBlockContainerView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.headerView)
        self.addSubview(contentView)
        self.addSubview(self.separatorView)
    }

    func makeConstraints() {
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.headerViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.headerViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.headerViewInsets.right)
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(self.shouldShowSeparator ? 1.0 : 0.0)
        }

        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.snp.makeConstraints { make in
            make.top
                .equalTo(self.headerView.snp.bottom)
                .offset(self.appearance.contentViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.contentViewInsets.left)
            make.trailing.equalToSuperview().offset(self.appearance.contentViewInsets.right)
            make.bottom
                .equalTo(self.separatorView.snp.top)
                .offset(-self.appearance.contentViewInsets.bottom)
        }
    }
}
