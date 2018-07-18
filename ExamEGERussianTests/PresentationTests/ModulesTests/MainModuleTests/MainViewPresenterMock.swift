//
//  MainViewPresenterMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 18/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
@testable import ExamEGERussian

final class MainViewPresenterMock: MainViewPresenter {
    var router: MainViewRouter

    init(router: MainViewRouter) {
        self.router = router
    }

    func viewWillAppear() {
    }

    func rightBarButtonPressed() {

    }

    func titleForRightBarButtonItem() -> String {
        return String(describing: self)
    }
}
