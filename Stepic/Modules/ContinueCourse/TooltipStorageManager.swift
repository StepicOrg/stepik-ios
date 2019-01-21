//
//  TooltipStorageManager.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 10.10.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol TooltipStorageManagerProtocol: class {
    var didShowOnHomeContinueLearning: Bool { get set }
    var didShowOnPersonalDeadlinesButton: Bool { get set }
}

@available(*, deprecated, message: "Code for backward compatibility")
final class TooltipStorageManager: TooltipStorageManagerProtocol {
    var didShowOnHomeContinueLearning: Bool {
        get {
            return TooltipDefaultsManager.shared.didShowOnHomeContinueLearning
        }
        set {
            TooltipDefaultsManager.shared.didShowOnHomeContinueLearning = newValue
        }
    }

    var didShowOnPersonalDeadlinesButton: Bool {
        get {
            return TooltipDefaultsManager.shared.didShowOnPersonalDeadlinesButton
        }
        set {
            TooltipDefaultsManager.shared.didShowOnPersonalDeadlinesButton = newValue
        }
    }

    init() { }
}
