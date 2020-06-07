import Foundation

protocol TooltipStorageManagerProtocol: AnyObject {
    var didShowOnHomeContinueLearning: Bool { get set }
    var didShowOnPersonalDeadlinesButton: Bool { get set }
    var didShowOnFullscreenCodeQuizTabRun: Bool { get set }
}

@available(*, deprecated, message: "Code for backward compatibility")
final class TooltipStorageManager: TooltipStorageManagerProtocol {
    var didShowOnHomeContinueLearning: Bool {
        get {
             TooltipDefaultsManager.shared.didShowOnHomeContinueLearning
        }
        set {
            TooltipDefaultsManager.shared.didShowOnHomeContinueLearning = newValue
        }
    }

    var didShowOnPersonalDeadlinesButton: Bool {
        get {
             TooltipDefaultsManager.shared.didShowOnPersonalDeadlinesButton
        }
        set {
            TooltipDefaultsManager.shared.didShowOnPersonalDeadlinesButton = newValue
        }
    }

    var didShowOnFullscreenCodeQuizTabRun: Bool {
        get {
            TooltipDefaultsManager.shared.didShowOnFullscreenCodeQuizTabRun
        }
        set {
            TooltipDefaultsManager.shared.didShowOnFullscreenCodeQuizTabRun = newValue
        }
    }

    init() {}
}
