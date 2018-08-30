//
//  CourseListCollectionViewDataSource.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 20.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class CourseListCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    var viewModels: [CourseWidgetViewModel]
    private var colorMode: CourseWidgetColorMode

    init(viewModels: [CourseWidgetViewModel] = [], colorMode: CourseWidgetColorMode = .default) {
        self.viewModels = viewModels
        self.colorMode = colorMode
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return self.viewModels.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: CourseListCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel: self.viewModels[indexPath.row], colorMode: self.colorMode)

        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let view: Stub = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, for: indexPath)
        view.backgroundColor = .red
        return view
    }
}
