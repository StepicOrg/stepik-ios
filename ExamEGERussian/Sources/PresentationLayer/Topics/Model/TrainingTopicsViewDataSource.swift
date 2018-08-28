//
//  TopicsViewDataSource.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 28/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class TrainingTopicsViewDataSource: NSObject, TopicsViewDataSourceProtocol {
    var topics: [TopicsViewData]

    init(topics: [TopicsViewData] = []) {
        self.topics = topics
        super.init()
    }

    func registerCells(for collectionView: UICollectionView) {
        collectionView.register(cellClass: TopicsCollectionCell.self)
        collectionView.register(
            viewClass: TopicsSectionView.self,
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
        )
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: TopicsCollectionCell = collectionView.dequeueReusableCell(for: indexPath)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionElementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let view: TopicsSectionView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionElementKindSectionHeader,
            for: indexPath
        )
        view.titleLabel.text = Section(rawValue: indexPath.section)?.title.uppercased()
        view.actionButton.setTitle(NSLocalizedString("See All", comment: ""), for: .normal)

        return view
    }
}

extension TrainingTopicsViewDataSource {
    enum Section: Int, CaseIterable {
        case theory
        case practice

        var title: String {
            switch self {
            case .theory:
                return NSLocalizedString("Theory", comment: "")
            case .practice:
                return NSLocalizedString("Practice", comment: "")
            }
        }
    }
}
