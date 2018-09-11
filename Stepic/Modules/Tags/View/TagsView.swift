//
//  TagsTagsView.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit
import SnapKit

extension TagsView {
    struct Appearance {
        let tagsEstimatedItemSize = CGSize(width: 80.0, height: 40.0)
        /// On iPhone Plus with iOS 10 we cannot use estimatedSize and should set itemSize
        let tagsPlusWorkaroundItemSize = CGSize(width: 205.0, height: 40.0)

        let tagsMinimumInteritemSpacing: CGFloat = 20
        let tagsMinimumLineSpacing: CGFloat = 20
    }
}

final class TagsView: UIView {
    let appearance: Appearance

    private lazy var headerView: ExploreBlockHeaderView = {
        let headerView = ExploreBlockHeaderView(frame: .zero)
        headerView.titleText = NSLocalizedString("TrendingTopics", comment: "")
        headerView.summaryText = nil
        headerView.shouldShowShowAllButton = false
        return headerView
    }()

    private lazy var tagsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.setEstimatedItemSize(
            self.appearance.tagsEstimatedItemSize,
            fallbackOnPlus: self.appearance.tagsPlusWorkaroundItemSize
        )
        layout.minimumLineSpacing = self.appearance.tagsMinimumLineSpacing
        layout.minimumInteritemSpacing = self.appearance.tagsMinimumInteritemSpacing

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.register(cellClass: TagsViewCollectionViewCell.self)
        return collectionView
    }()

    init(
        frame: CGRect,
        delegate: UICollectionViewDelegate,
        dataSource: UICollectionViewDataSource,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.tagsCollectionView.delegate = delegate
        self.tagsCollectionView.dataSource = dataSource

        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateCollectionViewData(
        delegate: UICollectionViewDelegate,
        dataSource: UICollectionViewDataSource
    ) {
        self.tagsCollectionView.dataSource = dataSource
        self.tagsCollectionView.reloadData()
        self.tagsCollectionView.collectionViewLayout.invalidateLayout()
    }
}

extension TagsView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.headerView)
        self.addSubview(self.tagsCollectionView)
    }

    func makeConstraints() {
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        self.tagsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.tagsCollectionView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.headerView.snp.bottom)
        }
    }
}
