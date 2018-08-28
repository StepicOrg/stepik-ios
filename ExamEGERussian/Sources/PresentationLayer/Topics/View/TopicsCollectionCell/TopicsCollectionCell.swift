//
//  TopicsCollectionCell.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 27/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class TopicsCollectionCell: UICollectionViewCell, Reusable, NibLoadable {
    @IBOutlet var collectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.register(cellClass: CardCollectionViewCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension TopicsCollectionCell: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 5
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: CardCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.titleLabel.text = "Title: \(indexPath.row + 1)"
        cell.bodyLabel.text = "Body goes here..."
        cell.commentLabel.text = "\(indexPath.row + 1)"

        return cell
    }
}

extension TopicsCollectionCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 240, height: collectionView.bounds.height)
    }
}
