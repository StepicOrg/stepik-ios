//
//  TagsTagsView.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit
import SnapKit

protocol TagsViewDelegate: class {
    func tagsViewDidTagSelect(_ tagsView: TagsView, viewModel: TagViewModel)
}

extension TagsView {
    struct Appearance {
        let headerTitleColor = UIColor(hex: 0x535366, alpha: 0.3)

        let tagsHeight: CGFloat = 40
        let tagsSpacing: CGFloat = 15
        let tagsViewInsets = UIEdgeInsets(top: 20, left: 16, bottom: 27, right: 16)

        let tagBackgroundColor = UIColor(hex: 0x535366, alpha: 0.06)
        let tagFont = UIFont.systemFont(ofSize: 16, weight: .light)
        let tagTextColor = UIColor.mainText
        let tagTitleInsets = UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16)
        let tagCornerRadius: CGFloat = 20
    }
}

final class TagsView: UIView {
    let appearance: Appearance
    weak var delegate: TagsViewDelegate?

    private var viewModels: [TagViewModel] = []

    private lazy var containerView: ExploreBlockContainerView = {
        var appearance = ExploreBlockContainerView.Appearance()
        appearance.contentViewInsets = self.appearance.tagsViewInsets

        return ExploreBlockContainerView(
            frame: .zero,
            headerView: self.headerView,
            contentView: self.tagsStackView,
            appearance: appearance
        )
    }()

    private lazy var headerView: ExploreBlockHeaderView = {
        var appearance = ExploreBlockHeaderView.Appearance()
        appearance.titleLabelColor = self.appearance.headerTitleColor

        let headerView = ExploreBlockHeaderView(frame: .zero, appearance: appearance)
        headerView.titleText = NSLocalizedString("TrendingTopics", comment: "")
        headerView.summaryText = nil
        headerView.shouldShowShowAllButton = false
        return headerView
    }()

    private lazy var tagsStackView: ScrollableStackView = {
        let stackView = ScrollableStackView(frame: .zero, orientation: .horizontal)
        stackView.showsHorizontalScrollIndicator = false
        stackView.spacing = self.appearance.tagsSpacing
        return stackView
    }()

    init(frame: CGRect, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateData(viewModels: [TagViewModel]) {
        self.viewModels = viewModels
        self.tagsStackView.removeAllArrangedViews()
        for (index, viewModel) in viewModels.enumerated() {
            let button = self.makeTagButton(title: viewModel.title)
            button.tag = index
            self.tagsStackView.addArrangedView(button)
        }
    }

    private func makeTagButton(title: String) -> UIView {
        let button = UIButton(type: .system)
        button.backgroundColor = self.appearance.tagBackgroundColor
        button.titleLabel?.font = self.appearance.tagFont
        button.tintColor = self.appearance.tagTextColor
        button.contentEdgeInsets = self.appearance.tagTitleInsets
        button.layer.cornerRadius = self.appearance.tagCornerRadius

        button.setTitle(title, for: .normal)
        button.addTarget(
            self,
            action: #selector(self.tagButtonClicked(sender:)),
            for: .touchUpInside
        )
        return button
    }

    @objc
    private func tagButtonClicked(sender: UIButton) {
        guard let viewModel = self.viewModels[safe: sender.tag] else {
            return
        }

        self.delegate?.tagsViewDidTagSelect(self, viewModel: viewModel)
    }
}

extension TagsView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.containerView)
    }

    func makeConstraints() {
        self.tagsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.tagsStackView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.tagsHeight)
        }

        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
