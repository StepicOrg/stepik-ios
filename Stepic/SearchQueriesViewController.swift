//
//  SearchQueriesViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit
import FLKAutoLayout

protocol SearchQueriesViewControllerDelegate: class {
    func didSelectSuggestion(suggestion: String)
}

class SearchQueriesViewController: UIViewController {
    var tableView: UITableView = UITableView()
    
    var presenter: SearchQueriesPresenter?
    
    weak var delegate: SearchQueriesViewControllerDelegate?
    
    var suggestions: [String] = []
    var query: String = "" {
        didSet {
            presenter?.getSuggestions(query: query)
        }
    }
    
    lazy var updatingView : LoadingPaginationView = {
        let paginationView = LoadingPaginationView()
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
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.align(to: self.view)
        tableView.register(UINib(nibName: "SearchSuggestionTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchSuggestionTableViewCell")
        presenter = SearchQueriesPresenter(view: self, queriesAPI: ApiDataDownloader.queries)
    }
}

extension SearchQueriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectSuggestion(suggestion: suggestions[indexPath.row])
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchSuggestionTableViewCell", for: indexPath) as? SearchSuggestionTableViewCell else {
            return UITableViewCell()
        }
        
        cell.suggestion = suggestions[indexPath.row]
        return cell
    }
}

extension SearchQueriesViewController : SearchQueriesView {
    func updateSuggestions(suggestions: [String]) {
        self.suggestions = suggestions
        tableView.reloadData()
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
                self?.tableView.tableFooterView = nil
            }
            break
        }
    }
    
}
