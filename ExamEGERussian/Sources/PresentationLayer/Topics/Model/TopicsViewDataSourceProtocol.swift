//
//  TopicsViewDataSource.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 28/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol TopicsViewDataSourceProtocol: UICollectionViewDataSource {
    var topics: [TopicsViewData] { get set }

    func registerCells(for collectionView: UICollectionView)
}
