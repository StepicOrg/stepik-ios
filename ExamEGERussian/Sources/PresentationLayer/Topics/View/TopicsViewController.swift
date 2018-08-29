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
    var presenter: TopicsPresenter!

    private let collectionView: UICollectionView
    private let collectionSource: TopicsCollectionViewSourceProtocol

    private var topics = [TopicPlainObject]() {
        didSet {
            collectionSource.topics = topics
            collectionView.reloadData()
            refreshControl.endRefreshing()
        }
    }

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)

        return refreshControl
    }()

    init(source: TopicsCollectionViewSourceProtocol,
         layout: UICollectionViewLayout = UICollectionViewFlowLayout()
    ) {
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionSource = source
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        presenter.refresh()
    }

    private func setup() {
        collectionSource.register(with: collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(self.view)
        }

        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.addSubview(refreshControl)
        collectionView.alwaysBounceVertical = true
    }

    @objc
    private func refreshData(_ sender: Any) {
        presenter.refresh()
    }
}

// MARK: - TopicsCollectionViewController: TopicsView -

extension TopicsViewController {
    func setTopics(_ topics: [TopicPlainObject]) {
        self.topics = topics
    }

    func displayError(title: String, message: String) {
        presentAlert(withTitle: title, message: message)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshControl.endRefreshing()
        }
    }
}
