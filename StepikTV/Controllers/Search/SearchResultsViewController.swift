//
//  SearchResultsViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 04.02.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class SearchResultsViewController: ItemsCollectionViewController, UISearchResultsUpdating {

    var presenter: SearchResultsPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = SearchResultsPresenter(view: self, coursesAPI: CoursesAPI(), progressesAPI: ProgressesAPI(), searchResultsAPI: SearchResultsAPI())
    }

    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        presenter?.updateSearchQuery(with: text)
    }

}

extension SearchResultsViewController: SearchResultsView {

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
