import Foundation

class AnalyticsEvent: Codable {
    let name: String
    let parameters: [String: Any]?

    init(name: String, parameters: [String: Any]? = nil) {
        self.name = name
        self.parameters = parameters
    }
}

final class AmplitudeAnalyticsEvent: AnalyticsEvent {}

final class StepikAnalyticsEvent: AnalyticsEvent {}
