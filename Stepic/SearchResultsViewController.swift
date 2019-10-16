//
//  SearchResultsViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 13.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

protocol SearchResultsModuleInputProtocol: class {
    func queryChanged(to query: String)
    func search(query: String)
    func searchStarted()
    func searchCancelled()
}

@available(*, deprecated, message: "Class for backward compatibility")
final class SearchResultsAssembly: Assembly {
    var moduleInput: SearchResultsModuleInputProtocol?
    private let updateQueryBlock: ((String) -> Void)?

    init(updateQueryBlock: ((String) -> Void)?) {
        self.updateQueryBlock = updateQueryBlock
    }

    func makeModule() -> UIViewController {
        guard let controller = ControllerHelper.instantiateViewController(
            identifier: "SearchResultsViewController",
            storyboardName: "Explore"
        ) as? SearchResultsViewController else {
            fatalError("Failed to init module from storyboard")
        }

        controller.presenter = SearchResultsPresenter(view: controller)
        controller.presenter?.updateQueryBlock = updateQueryBlock

        self.moduleInput = controller.presenter

        return controller
    }
}

final class SearchResultsViewController: UIViewController, SearchResultsView {
    var presenter: SearchResultsPresenter?
    var suggestionsVC: UIViewController?
    var coursesVC: UIViewController?

    var state = CoursesSearchResultsState.waiting {
        didSet {
            switch state {
            case .courses:
                removeController(forState: .suggestions)
            case .suggestions:
                removeController(forState: .courses)
            case .waiting:
                removeController(forState: .courses)
                removeController(forState: .suggestions)
            }
            updateUIForCurrentState()
        }
    }

    private func updateUIForCurrentState() {
        switch state {
        case .courses:
            self.view.isHidden = false
            coursesVC?.view.isHidden = false
            suggestionsVC?.view.isHidden = true
            self.view.alpha = 1
        case .suggestions:
            self.view.isHidden = false
            suggestionsVC?.view.isHidden = false
            coursesVC?.view.isHidden = true
            self.view.alpha = 1
        case .waiting:
            self.view.isHidden = false
            suggestionsVC?.view.isHidden = true
            coursesVC?.view.isHidden = true
            self.view.backgroundColor = UIColor.mainDark
            self.view.alpha = 0
            UIView.animate(withDuration: 0.2, animations: {
                self.view.alpha = 0.6
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = []

        updateUIForCurrentState()
    }

    func set(state: CoursesSearchResultsState) {
        self.state = state
    }

    func set(controller: UIViewController, forState: CoursesSearchResultsState) {
        switch forState {
        case .courses:
            coursesVC = controller
        case .suggestions:
            suggestionsVC = controller
        default:
            return
        }
        self.addChild(controller)
        self.view.addSubview(controller.view)
        controller.view.isHidden = true
        controller.view.snp.makeConstraints { $0.edges.equalTo(self.view) }
    }

    func removeController(forState: CoursesSearchResultsState) {
        switch forState {
        case .courses:
            coursesVC?.removeFromParent()
            coursesVC?.view.removeFromSuperview()
            coursesVC = nil
        case .suggestions:
            suggestionsVC?.removeFromParent()
            suggestionsVC?.view.removeFromSuperview()
            suggestionsVC = nil
        case .waiting:
            break
        }
    }
}
