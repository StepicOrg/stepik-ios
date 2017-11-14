//
//  NewSearchResultsViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 13.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class NewSearchResultsViewController: UIViewController, SearchResultsView {
    var presenter: SearchResultsPresenter?
    var suggestionsVC: UIViewController?
    var coursesVC: UIViewController?

    var state: CoursesSearchResultsState = CoursesSearchResultsState.waiting {
        didSet {
            updateUIForCurrentState()
        }
    }

    private func updateUIForCurrentState() {
        switch state {
        case .courses:
            coursesVC?.view.isHidden = false
            suggestionsVC?.view.isHidden = true
            self.view.alpha = 1
            break
        case .suggestions:
            suggestionsVC?.view.isHidden = false
            coursesVC?.view.isHidden = true
            self.view.alpha = 1
            break
        case .waiting:
            suggestionsVC?.view.isHidden = true
            coursesVC?.view.isHidden = true
            self.view.backgroundColor = UIColor.mainDark
            self.view.alpha = 0
            UIView.animate(withDuration: 0.2, animations: {
                self.view.alpha = 0.6
            })
            break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.addChildViewController(controller)
        self.view.addSubview(controller.view)
        controller.view.isHidden = true
        controller.view.align(toView: self.view)
    }
}
