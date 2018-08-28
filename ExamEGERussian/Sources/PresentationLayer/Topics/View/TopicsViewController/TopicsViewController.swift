//
//  TopicsViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 27/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

final class TopicsViewController: UIViewController, TopicsView {
    private let collectionView: UICollectionView
    private let dataSource: TopicsViewDataSourceProtocol
    private let delegate: UICollectionViewDelegate? // swiftlint:disable:this weak_delegate

    init(dataSource: TopicsViewDataSourceProtocol,
         delegate: UICollectionViewDelegate? = nil,
         layout: UICollectionViewLayout = UICollectionViewFlowLayout()
    ) {
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.dataSource = dataSource
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)

        self.collectionView.dataSource = dataSource
        self.collectionView.delegate = delegate
        dataSource.registerCells(for: self.collectionView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(self.view)
        }

        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
    }
}

// MARK: - TopicsCollectionViewController: TopicsView -

extension TopicsViewController {
    func setTopics(_ topics: [TopicsViewData]) {

    }

    func setSegments(_ segments: [String]) {

    }

    func selectSegment(at index: Int) {

    }

    func displayError(title: String, message: String) {

    }
}
