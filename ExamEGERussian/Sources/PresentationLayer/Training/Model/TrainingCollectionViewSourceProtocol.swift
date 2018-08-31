//
//  TrainingCollectionViewSourceProtocol.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 28/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol TrainingCollectionViewSourceProtocol: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var topics: [TopicPlainObject] { get set }

    func register(with collectionView: UICollectionView)
}
