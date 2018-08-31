//
//  TrainingHorizontalCollectionSource.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 28/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class TrainingHorizontalCollectionSource: NSObject {
    var topics: [TopicPlainObject]
    var didSelectItem: ((_ topic: TopicPlainObject) -> Void)?

    init(topics: [TopicPlainObject] = []) {
        self.topics = topics
        super.init()
    }

    func register(for collectionView: UICollectionView) {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellClass: TrainingCardCollectionViewCell.self)
    }
}

extension TrainingHorizontalCollectionSource: UICollectionViewDataSource {
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
        let cell: TrainingCardCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.titleLabel.text = topic.title
        cell.bodyLabel.text = topic.description
        cell.commentLabel.text = "\(topic.lessons.count) pages"

        return cell
    }
}

extension TrainingHorizontalCollectionSource: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 240, height: collectionView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItem?(topics[indexPath.row])
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}
