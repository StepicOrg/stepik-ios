//
//  AdaptiveCourseSelectPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.02.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol AdaptiveCourseSelectView: class {
    var state: AdaptiveCourseSelectViewState { get set }

    func set(data: [AdaptiveCourseSelectViewData])
}

typealias AdaptiveCourseSelectViewData = (id: Int, name: String, cover: URL?)

class AdaptiveCourseSelectPresenter {
    weak var view: AdaptiveCourseSelectView?

    var initialActions: (((([Course]) -> Void)?, ((Error) -> Void)?) -> Void)?
    private var courses: [Course] = []

    init(view: AdaptiveCourseSelectView) {
        self.view = view
    }

    func refresh() {
        view?.state = .loading

        DispatchQueue.global().async { [weak self] in
            if let actions = self?.initialActions {
                actions({ courses -> Void in
                    self?.courses = courses
                    self?.reloadData(courses: courses)
                }, { error in
                    if let error = error as? AdaptiveCardsStepsError {
                        switch error {
                        case .noProfile, .userNotUnregisteredFromEmails:
                            break
                        default:
                            self?.view?.state = .error
                        }
                    }
                })
            }
        }
    }

    private func reloadData(courses: [Course]) {
        let viewData = courses.map { (id: $0.id, name: $0.title, cover:  URL(string: $0.coverURLString)) }
        view?.set(data: viewData)
    }

    func tryAgain() {
        refresh()
    }
}
