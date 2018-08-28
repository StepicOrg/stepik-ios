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

    var source: TopicsCollectionSource? = nil {
        didSet {
            source?.register(for: collectionView)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.showsHorizontalScrollIndicator = false
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        source = nil
    }
}
