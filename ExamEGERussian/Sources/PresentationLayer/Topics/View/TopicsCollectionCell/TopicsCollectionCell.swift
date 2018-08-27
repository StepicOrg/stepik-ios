//
//  TopicsCollectionCell.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 27/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class TopicsCollectionCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet var collectionView: UICollectionView!

    private static let reuseIdentifier = String(describing: TopicCollectionViewCell.self)

    override func awakeFromNib() {
        super.awakeFromNib()

        let cellNib = UINib(nibName: TopicsCollectionCell.reuseIdentifier, bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: TopicsCollectionCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TopicsCollectionCell.reuseIdentifier,
            for: indexPath
        ) as! TopicCollectionViewCell
        cell.titleLabel.text = "Title: \(indexPath.row + 1)"
        cell.bodyLabel.text = "Body goes here..."
        cell.commentLabel.text = "\(indexPath.row + 1)"

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 240, height: collectionView.bounds.height)
    }
}
