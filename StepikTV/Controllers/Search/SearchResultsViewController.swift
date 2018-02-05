//
//  SearchResultsViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 04.02.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class SearchResultsViewController: ItemsCollectionViewController, UISearchResultsUpdating {

    var search: CourseListType

    var filterString = "" {
        didSet {
            // Return if the filter string hasn't changed.
            guard filterString != oldValue else { return }

            /*
            CourseListType.search(query: filterString).request(page: , language: , withAPI: , progressesAPI: , searchResultsAPI: )
 */

            // Apply the filter or show all items if the filter string is empty.
            if filterString.isEmpty {
                filteredDataItems = allDataItems
            }
            else {
                filteredDataItems = allDataItems.filter { $0.title.localizedStandardContains(filterString) }
            }

            // Reload the collection view to reflect the changes.
            collectionView?.reloadData()
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        
    }

}
