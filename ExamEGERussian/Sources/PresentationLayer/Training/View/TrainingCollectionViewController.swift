//
//  TrainingCollectionViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 31/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class TrainingCollectionViewController: UICollectionViewController, TrainingView {
    var presenter: TrainingPresenterProtocol!
    private var viewData = [TrainingViewData]()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        return refreshControl
    }()

    private var isFirstTimeWillAppear = true

    // MARK: - Init

    override init(collectionViewLayout: UICollectionViewLayout = UICollectionViewFlowLayout()) {
        super.init(collectionViewLayout: collectionViewLayout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isFirstTimeWillAppear {
            isFirstTimeWillAppear = false
            presenter.refresh()
        }
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.count
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 1
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: TrainingHorizontalCollectionCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.source = TrainingHorizontalCollectionSource(viewData: getViewData(for: indexPath))
        cell.source?.didSelectItem = presenter.selectViewData

        return cell
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionElementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let view: TrainingSectionView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionElementKindSectionHeader,
            for: indexPath
        )
        view.titleLabel.text = Section(rawValue: indexPath.section)?.title.uppercased()
        view.actionButton.setTitle(NSLocalizedString("See All", comment: ""), for: .normal)

        return view
    }

    // MARK: - TrainingView

    func setViewData(_ viewData: [TrainingViewData]) {
        self.viewData = viewData
        refreshControl.endRefreshing()
        collectionView?.reloadData()
    }

    func displayError(title: String, message: String) {
        presentAlert(withTitle: title, message: message)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshControl.endRefreshing()
        }
    }

    // MARK: - Private API

    private func setup() {
        collectionView?.register(cellClass: TrainingHorizontalCollectionCell.self)
        collectionView?.register(
            viewClass: TrainingSectionView.self,
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
        )
        collectionView?.backgroundColor = .white
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.alwaysBounceVertical = true
        collectionView?.addSubview(refreshControl)
    }

    @objc
    private func refreshData(_ sender: Any) {
        presenter.refresh()
    }

    private func getViewData(for indexPath: IndexPath) -> [TrainingViewData] {
        switch Section.from(indexPath: indexPath) {
        case .theory:
            return viewData.filter { $0.isPractice == false }
        case .practice:
            return viewData.filter { $0.isPractice == true }
        }
    }

    // MARK: - Types

    private enum Section: Int {
        case theory
        case practice

        var title: String {
            switch self {
            case .theory:
                return NSLocalizedString("Theory", comment: "")
            case .practice:
                return NSLocalizedString("Practice", comment: "")
            }
        }

        static let count: Int = {
            var count = 0
            while let _ = Section(rawValue: count) {
                count += 1
            }
            return count
        }()

        static func from(indexPath: IndexPath) -> Section {
            return Section(rawValue: indexPath.section)!
        }
    }
}

// MARK: - TrainingCollectionViewController: UICollectionViewDelegateFlowLayout -

extension TrainingCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 200)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 54)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        if section == collectionView.numberOfSections - 1 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        }

        return .zero
    }
}
