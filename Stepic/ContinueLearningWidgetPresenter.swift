//
//  ContinueLearningWidgetPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 25.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol ContinueLearningWidgetView: class {

}

class ContinueLearningWidgetPresenter {
    weak var view: ContinueLearningWidgetView?
    init(view: ContinueLearningWidgetView) {
        self.view = view
    }

    func getContinueLearningContent() {

    }
}
