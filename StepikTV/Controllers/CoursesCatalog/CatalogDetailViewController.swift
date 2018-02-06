//
//  CatalogDetailViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 02.02.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class CatalogDetailViewController: ItemsCollectionViewController {

}

extension CatalogDetailViewController: CatalogDetailView {

    func showLoading(with width: Float) {

        let rect = CGRect(x: 0, y: 0, width: CGFloat(width), height: UIScreen.main.bounds.height)

        guard let _ = loadingView else {

            loadingView = TVLoadingView(frame: rect, color: .gray)
            loadingView!.setup()

            self.view.addSubview(loadingView!)
            return
        }
    }

    func hideLoading() {
        loadingView?.purge()
        loadingView?.removeFromSuperview()

        loadingView = nil
    }

    func provide(items: [ItemViewData]) {
        sectionCourses = items
        collectionView?.reloadData()
    }

    func update() {
        collectionView?.reloadData()
    }

    func add(item: ItemViewData) {
        sectionCourses.append(item)
        collectionView?.reloadData()
    }

    func remove(itemWithId id: Int) {
        sectionCourses = sectionCourses.filter { $0.id! != id }
        collectionView?.reloadData()
    }

}
