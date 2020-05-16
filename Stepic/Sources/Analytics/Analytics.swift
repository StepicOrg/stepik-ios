import Foundation

protocol Analytics {
    func send(_ event: AnalyticsEvent)
}

final class StepikAnalytics: Analytics {
    static let shared = StepikAnalytics()

    private let amplitudeAnalyticsEngine: AnalyticsEngine
    private let firebaseAnalyticsEngine: AnalyticsEngine
    private let appMetricaAnalyticsEngine: AnalyticsEngine

    private init(
        amplitudeAnalyticsEngine: AnalyticsEngine = AmplitudeAnalyticsEngine(),
        firebaseAnalyticsEngine: AnalyticsEngine = FirebaseAnalyticsEngine(),
        appMetricaAnalyticsEngine: AnalyticsEngine = AppMetricaAnalyticsEngine()
    ) {
        self.amplitudeAnalyticsEngine = amplitudeAnalyticsEngine
        self.firebaseAnalyticsEngine = firebaseAnalyticsEngine
        self.appMetricaAnalyticsEngine = appMetricaAnalyticsEngine
    }

    func send(_ event: AnalyticsEvent) {
        // Sends Amplitude events to Amplitude backend and also mirrors these events to AppMetrica.
        // Otherwise, sends the current event to AppMetrica and FirebaseAnalytics backends.
        if event is AmplitudeAnalyticsEvent {
            self.amplitudeAnalyticsEngine.sendAnalyticsEvent(named: event.name, parameters: event.parameters)
            self.appMetricaAnalyticsEngine.sendAnalyticsEvent(named: event.name, parameters: event.parameters)
        } else {
            self.firebaseAnalyticsEngine.sendAnalyticsEvent(named: event.name, parameters: event.parameters)
            self.appMetricaAnalyticsEngine.sendAnalyticsEvent(named: event.name, parameters: event.parameters)
        }
    }
}
