import Foundation

/// Command-line arguments passed on launch.
enum LaunchArguments {
    static var analyticsDebugEnabled = Self.hasArgument("-com.AlexKarpov.Stepic.AnalyticsDebugEnabled")

    static var spotlightIndexingDebugEnabled = Self.hasArgument("-com.AlexKarpov.Stepic.SpotlightIndexingDebugEnabled")

    static var flexShowExplorerOnLaunch = Self.hasArgument("-com.AlexKarpov.Stepic.FLEXShowExplorerOnLaunch")

    static var isNetworkDebuggingEnabled = Self.hasArgument("-com.AlexKarpov.Stepic.IsNetworkDebuggingEnabled")

    private static func hasArgument(_ argument: String) -> Bool {
        CommandLine.arguments.contains(argument)
    }
}
