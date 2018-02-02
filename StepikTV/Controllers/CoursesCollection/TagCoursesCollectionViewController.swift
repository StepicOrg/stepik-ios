//
//  TagCoursesCollectionViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 02.02.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class TagCoursesCollectionViewController: ItemsCollectionViewController {

    var presenter: TagCoursesCollectionPresenter?

}

extension TagCoursesCollectionViewController: TagCoursesCollectionView {
    
    func showLoading(isVisible: Bool) {

        guard isVisible else {
            loadingView?.purge()
            loadingView?.removeFromSuperview()
            loadingView = nil
            return
        }

        guard let _ = loadingView else {

            loadingView = TVLoadingView(frame: self.view.bounds, color: .gray)
            loadingView!.setup()

            self.view.addSubview(loadingView!)
            return
        }
    }

    func provide(items: [ItemViewData]) {
        sectionCourses = items
    }
}
