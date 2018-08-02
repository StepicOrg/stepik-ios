//
// Created by Ivan Magda on 02/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum StepsPagerViewState {
    case idle
    case fetching
    case fetched(steps: [StepPlainObject])
    case error(message: String)
}

protocol StepsPagerView: class {
    var state: StepsPagerViewState { get set }
}
