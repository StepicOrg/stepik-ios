//
//  CourseListCollectionViewDelegate.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 20.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class CourseListCollectionViewDelegate: NSObject, UICollectionViewDelegate {
    weak var delegate: CourseListViewControllerDelegate?

    var viewModels: [CourseWidgetViewModel]

    init(viewModels: [CourseWidgetViewModel] = []) {
        self.viewModels = viewModels
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer {
            collectionView.deselectItem(at: indexPath, animated: true)
        }

        guard let viewModel = self.viewModels[safe: indexPath.row] else {
            return
        }

        delegate?.itemDidSelected(viewModel: viewModel)
    }
}
