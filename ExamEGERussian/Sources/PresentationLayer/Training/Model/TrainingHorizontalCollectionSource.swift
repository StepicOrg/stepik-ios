//
//  TrainingHorizontalCollectionSource.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 28/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class TrainingHorizontalCollectionSource: NSObject {
    var viewData: [TrainingViewData]
    var didSelectItem: ((_ topic: TrainingViewData) -> Void)?

    init(viewData: [TrainingViewData] = []) {
        self.viewData = viewData
        super.init()
    }

    func register(for collectionView: UICollectionView) {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellClass: TrainingCardCollectionViewCell.self)
    }
}

extension TrainingHorizontalCollectionSource: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewData.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let viewData = self.viewData[indexPath.row]
        let cell: TrainingCardCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.titleLabel.text = viewData.title
        cell.bodyLabel.text = viewData.description
        cell.commentLabel.text = viewData.isPractice
            ? nil
            : pagesPluralized(count: viewData.countLessons)

        return cell
    }

    private func pagesPluralized(count: Int) -> String {
        let pluralizedString = StringHelper.pluralize(number: count, forms: [
            NSLocalizedString("PagesCountText1", comment: ""),
            NSLocalizedString("PagesCountText234", comment: ""),
            NSLocalizedString("PagesCountText567890", comment: "")
        ])

        return String(format: pluralizedString, "\(count)")
    }
}

extension TrainingHorizontalCollectionSource: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 240, height: collectionView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItem?(viewData[indexPath.row])
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}
