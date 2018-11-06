//
//  SearchQueriesViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit

protocol SearchQueriesViewControllerDelegate: class {
    func didSelectSuggestion(suggestion: String, position: Int)
}

class SearchQueriesViewController: UIViewController {
    var tableView: UITableView = UITableView()

    var presenter: SearchQueriesPresenter?

    var hideKeyboardBlock: (() -> Void)?

    weak var delegate: SearchQueriesViewControllerDelegate?

    var suggestions: [String] = []
    var query: String = "" {
        didSet {
            presenter?.getSuggestions(query: query)
        }
    }

    lazy var updatingView: LoadingPaginationView = {
        let paginationView = LoadingPaginationView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 40))
        paginationView.refreshAction = {
            [weak self] in

            guard let presenter = self?.presenter, let query = self?.query else {
                return
            }

            presenter.getSuggestions(query: query)
        }

        return paginationView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = []

        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalTo(self.view) }
        tableView.register(UINib(nibName: "SearchSuggestionTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchSuggestionTableViewCell")
        presenter = SearchQueriesPresenter(view: self, queriesAPI: ApiDataDownloader.queries, persistentManager: SearchQueriesPersistentManager())
        tableView.tableFooterView = UIView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        suggestions = []
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideKeyboardBlock?()
    }
}

extension SearchQueriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelect(suggestion: suggestions[indexPath.row])
        delegate?.didSelectSuggestion(suggestion: suggestions[indexPath.row], position: indexPath.row)
    }
}

extension SearchQueriesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard suggestions.count > indexPath.row, let cell = tableView.dequeueReusableCell(withIdentifier: "SearchSuggestionTableViewCell", for: indexPath) as? SearchSuggestionTableViewCell else {
            return UITableViewCell()
        }

        cell.set(suggestion: suggestions[indexPath.row], query: query)
        return cell
    }
}

extension SearchQueriesViewController : SearchQueriesView {
    func updateSuggestions(suggestions: [String]) {
        DispatchQueue.main.async {
            [weak self] in
            self?.suggestions = suggestions
            self?.tableView.reloadData()
        }
    }

    func setState(state: SearchQueriesState) {
        switch state {
        case .error:
            DispatchQueue.main.async {
                [weak self] in
                self?.updatingView.setError()
                self?.tableView.tableFooterView = self?.updatingView
            }
            break
        case .updating:
            DispatchQueue.main.async {
                [weak self] in
                self?.updatingView.setLoading()
                self?.tableView.tableFooterView = self?.updatingView
            }
            break
        case.ok:
            DispatchQueue.main.async {
                [weak self] in
                self?.tableView.tableFooterView = UIView()
            }
            break
        }
    }

}
