//
//  TopicsViewSourceProtocol.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 28/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol TopicsViewSourceProtocol: UICollectionViewDataSource {
    var topics: [TopicPlainObject] { get set }
    var delegate: TopicsViewSourceDelegate? { get set }

    func registerCells(for collectionView: UICollectionView)
}

protocol TopicsViewSourceDelegate: class {
    func didSelectTopic(_ topic: TopicPlainObject)
}

extension TopicsViewSourceDelegate {
    func didSelectTopic(_ topic: TopicPlainObject) {
    }
}
