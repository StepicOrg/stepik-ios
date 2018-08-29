//
//  LearningTopicsViewDataSource.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 29/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class LearningTopicsViewDataSource: NSObject, TopicsViewDataSourceProtocol {
    var topics: [TopicPlainObject]
    var didSelectTopic: ((_ topic: TopicPlainObject) -> Void)?

    init(topics: [TopicPlainObject] = []) {
        self.topics = topics
        super.init()
    }

    func register(with collectionView: UICollectionView) {
        collectionView.register(cellClass: CardCollectionViewCell.self)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return topics.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let topic = topics[indexPath.row]
        let cell: CardCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.titleLabel.text = topic.title
        cell.bodyLabel.text = topic.description
        cell.commentLabel.text = "\(topic.lessons.count) pages"

        return cell
    }
}

extension LearningTopicsViewDataSource: UICollectionViewDelegateFlowLayout {
    private static let sectionInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let horizontalSpacing = LearningTopicsViewDataSource.sectionInsets.left
            + LearningTopicsViewDataSource.sectionInsets.right
        return CGSize(width: collectionView.bounds.width - horizontalSpacing, height: 180)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return LearningTopicsViewDataSource.sectionInsets
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 20
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        didSelectTopic?(topics[indexPath.row])
    }
}
