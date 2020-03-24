//
//  SearchQueriesViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

protocol SearchQueriesViewControllerDelegate: AnyObject {
    func didSelectSuggestion(suggestion: String, position: Int)
}

final class SearchQueriesViewController: UIViewController {
    private var tableView = UITableView()

    var presenter: SearchQueriesPresenter?

    weak var delegate: SearchQueriesViewControllerDelegate?

    private var suggestions: [String] = []
    var query: String = "" {
        didSet {
            presenter?.getSuggestions(query: query)
        }
    }

    private lazy var updatingView: LoadingPaginationView = {
        let paginationView = LoadingPaginationView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 40))
        paginationView.refreshAction = { [weak self] in
            guard let presenter = self?.presenter, let query = self?.query else {
                return
            }

            presenter.getSuggestions(query: query)
        }

        return paginationView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = []

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableView.automaticDimension

        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { $0.edges.equalTo(self.view) }

        self.tableView.register(
            UINib(nibName: "SearchSuggestionTableViewCell", bundle: nil),
            forCellReuseIdentifier: "SearchSuggestionTableViewCell"
        )

        self.tableView.tableFooterView = UIView()
        self.tableView.keyboardDismissMode = .onDrag

        self.presenter = SearchQueriesPresenter(
            view: self,
            queriesAPI: ApiDataDownloader.queries,
            persistentManager: SearchQueriesPersistentManager()
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.suggestions = []
    }
}

extension SearchQueriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter?.didSelect(suggestion: self.suggestions[indexPath.row])
        self.delegate?.didSelectSuggestion(suggestion: self.suggestions[indexPath.row], position: indexPath.row)
    }
}

extension SearchQueriesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { self.suggestions.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard self.suggestions.count > indexPath.row,
              let cell = tableView.dequeueReusableCell(
                withIdentifier: "SearchSuggestionTableViewCell",
                for: indexPath
        ) as? SearchSuggestionTableViewCell else {
            return UITableViewCell()
        }

        cell.set(suggestion: self.suggestions[indexPath.row], query: self.query)

        return cell
    }
}

extension SearchQueriesViewController: SearchQueriesView {
    func updateSuggestions(suggestions: [String]) {
        self.suggestions = suggestions
        self.tableView.reloadData()
    }

    func setState(state: SearchQueriesState) {
        switch state {
        case .error:
            self.updatingView.setError()
            self.tableView.tableFooterView = self.updatingView
        case .updating:
            self.updatingView.setLoading()
            self.tableView.tableFooterView = self.updatingView
        case.ok:
            self.tableView.tableFooterView = UIView()
        }
    }
}
