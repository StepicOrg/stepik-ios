//
//  TrainingTopicsCollectionSource.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 28/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class TrainingTopicsCollectionSource: NSObject, TrainingCollectionViewSourceProtocol {
    var topics: [TopicPlainObject]
    var didSelectTopic: ((_ topic: TopicPlainObject) -> Void)?

    init(topics: [TopicPlainObject] = []) {
        self.topics = topics
        super.init()
    }

    func register(with collectionView: UICollectionView) {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellClass: TrainingHorizontalCollectionCell.self)
        collectionView.register(
            viewClass: TrainingSectionView.self,
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
        let cell: TrainingHorizontalCollectionCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.source = TrainingHorizontalCollectionSource(topics: topics(for: indexPath))
        cell.source?.didSelectItem = didSelectTopic

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

        let view: TrainingSectionView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionElementKindSectionHeader,
            for: indexPath
        )
        view.titleLabel.text = Section(rawValue: indexPath.section)?.title.uppercased()
        view.actionButton.setTitle(NSLocalizedString("See All", comment: ""), for: .normal)

        return view
    }

    private func topics(for indexPath: IndexPath) -> [TopicPlainObject] {
        switch Section.from(indexPath: indexPath) {
        case .theory:
            return topics
        case .practice:
            return topics.filter { $0.type == .practice }
        }
    }

    private enum Section: Int, CaseIterable {
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

        static func from(indexPath: IndexPath) -> Section {
            return Section(rawValue: indexPath.section)!
        }
    }
}

extension TrainingTopicsCollectionSource: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 200)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 54)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        if section == collectionView.numberOfSections - 1 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        }

        return .zero
    }
}
