//
//  TagsCollectionViewDataSource.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 11.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class TagsCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    var viewModels: [TagViewModel]

    init(viewModels: [TagViewModel] = []) {
        self.viewModels = viewModels
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
        let cell: TagsViewCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel: self.viewModels[indexPath.row])

        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale

        return cell
    }
}
