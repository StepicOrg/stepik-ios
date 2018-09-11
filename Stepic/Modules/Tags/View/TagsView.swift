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

    }
}

final class TagsView: UIView {
    let appearance: Appearance

    private lazy var headerView: ExploreBlockHeaderView = {
        let headerView = ExploreBlockHeaderView(frame: .zero)
        headerView.titleText = "Trending topics"
        headerView.summaryText = nil
        headerView.shouldShowShowAllButton = false
        return headerView
    }()

    private lazy var tagsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        return collectionView
    }()

    init(
        frame: CGRect, 
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
