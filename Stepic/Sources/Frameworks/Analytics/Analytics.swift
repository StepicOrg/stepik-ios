import Foundation

protocol Analytics {
    func send(_ event: AnalyticsEvent, forceSend: Bool)
}

extension Analytics {
    func send(_ event: AnalyticsEvent) {
        self.send(event, forceSend: false)
    }

    func send(_ events: AnalyticsEvent..., forceSend: Bool = false) {
        events.forEach { event in
            self.send(event, forceSend: forceSend)
        }
    }
}

final class StepikAnalytics: Analytics {
    static let shared = StepikAnalytics()

    private let amplitudeAnalyticsEngine: AnalyticsEngine
    private let firebaseAnalyticsEngine: AnalyticsEngine
    private let appMetricaAnalyticsEngine: AnalyticsEngine
    private let stepikAnalyticsEngine: AnalyticsEngine

    private init(
        amplitudeAnalyticsEngine: AnalyticsEngine = AmplitudeAnalyticsEngine(),
        firebaseAnalyticsEngine: AnalyticsEngine = FirebaseAnalyticsEngine(),
        appMetricaAnalyticsEngine: AnalyticsEngine = AppMetricaAnalyticsEngine(),
        stepikAnalyticsEngine: AnalyticsEngine = StepikAnalyticsEngine()
    ) {
        self.amplitudeAnalyticsEngine = amplitudeAnalyticsEngine
        self.firebaseAnalyticsEngine = firebaseAnalyticsEngine
        self.appMetricaAnalyticsEngine = appMetricaAnalyticsEngine
        self.stepikAnalyticsEngine = stepikAnalyticsEngine
    }

    func send(_ event: AnalyticsEvent, forceSend: Bool) {
        // Sends Amplitude events to Amplitude backend and also mirrors these events to AppMetrica & FirebaseAnalytics.
        // Otherwise, sends the current event to AppMetrica and FirebaseAnalytics backends.
        if event is AmplitudeAnalyticsEvent {
            self.amplitudeAnalyticsEngine.sendAnalyticsEvent(
                named: event.name,
                parameters: event.parameters,
                forceSend: forceSend
            )
            self.appMetricaAnalyticsEngine.sendAnalyticsEvent(
                named: event.name,
                parameters: event.parameters,
                forceSend: forceSend
            )
            self.firebaseAnalyticsEngine.sendAnalyticsEvent(
                named: event.name,
                parameters: event.parameters,
                forceSend: forceSend
            )
        } else if event is StepikAnalyticsEvent {
            self.stepikAnalyticsEngine.sendAnalyticsEvent(
                named: event.name,
                parameters: event.parameters,
                forceSend: forceSend
            )
        } else {
            self.firebaseAnalyticsEngine.sendAnalyticsEvent(
                named: event.name,
                parameters: event.parameters,
                forceSend: forceSend
            )
            self.appMetricaAnalyticsEngine.sendAnalyticsEvent(
                named: event.name,
                parameters: event.parameters,
                forceSend: forceSend
            )
        }
    }
}
