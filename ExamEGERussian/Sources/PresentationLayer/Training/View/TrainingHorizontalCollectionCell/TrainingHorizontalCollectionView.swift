//
//  TrainingHorizontalCollectionView.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 29/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class TrainingHorizontalCollectionView: UICollectionView {
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        alwaysBounceHorizontal = true
        backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
