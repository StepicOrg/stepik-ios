import Foundation

#if BETA_PROFILE || DEBUG
import FLEX
#endif

enum FLEXManager {
    static func setup() {
        #if BETA_PROFILE || DEBUG
        FLEX.FLEXManager.shared.isNetworkDebuggingEnabled = true
        #endif

        #if DEBUG
        FLEX.FLEXManager.shared.showExplorer()
        #endif
    }

    static func toggleExplorer() {
        #if BETA_PROFILE || DEBUG
        FLEX.FLEXManager.shared.toggleExplorer()
        #endif
    }

    static func makeMenuViewController() -> UIViewController? {
        #if BETA_PROFILE || DEBUG
        return FLEX.FLEXGlobalsViewController()
        #else
        return nil
        #endif
    }
}
