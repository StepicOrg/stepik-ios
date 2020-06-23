import Amplitude_iOS
import FirebaseAnalytics
import Foundation
import YandexMobileMetrica

protocol AnalyticsEngine: AnyObject {
    func sendAnalyticsEvent(named name: String, parameters: [String: Any]?)
}

extension AnalyticsEngine {
    func sendAnalyticsEvent(named name: String) {
        self.sendAnalyticsEvent(named: name, parameters: nil)
    }
}

// MARK: - AmplitudeAnalyticsEngine: AnalyticsEngine -

final class AmplitudeAnalyticsEngine: AnalyticsEngine {
    private let instance: Amplitude

    init(instance: Amplitude = Amplitude.instance()) {
        self.instance = instance
    }

    func sendAnalyticsEvent(named name: String, parameters: [String: Any]?) {
        self.instance.logEvent(name, withEventProperties: parameters)
        print("Logging Amplitude event: \(name), parameters: \(String(describing: parameters)))")
    }
}

// MARK: - FirebaseAnalyticsEngine: AnalyticsEngine -

final class FirebaseAnalyticsEngine: AnalyticsEngine {
    init() {}

    func sendAnalyticsEvent(named name: String, parameters: [String: Any]?) {
        FirebaseAnalytics.Analytics.logEvent(name, parameters: parameters)
        print("Logging Firebase event: \(name), parameters: \(String(describing: parameters))")
    }
}

// MARK: - AppMetricaAnalyticsEngine: AnalyticsEngine -

final class AppMetricaAnalyticsEngine: AnalyticsEngine {
    init() {}

    func sendAnalyticsEvent(named name: String, parameters: [String: Any]?) {
        YMMYandexMetrica.reportEvent(name, parameters: parameters)
        print("Logging AppMetrica event: \(name), parameters: \(String(describing: parameters))")
    }
}

// MARK: - StepikAnalyticsEngine: AnalyticsEngine -

final class StepikAnalyticsEngine: AnalyticsEngine {
    private static let batchSize = 30

    private let stepikMetricsNetworkService: StepikMetricsNetworkServiceProtocol

    private var queue = Queue<AnalyticsEvent>()

    private let synchronizationQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.StepikAnalyticsEngine",
        qos: .background
    )
    // TODO: Replace with pthread_mutex_t
    private let lock = NSLock()

    private var hasOngoingRequest = false

    init(stepikMetricsNetworkService: StepikMetricsNetworkServiceProtocol = StepikMetricsNetworkService()) {
        self.stepikMetricsNetworkService = stepikMetricsNetworkService
    }

    // MARK: Protocol Conforming

    func sendAnalyticsEvent(named name: String, parameters: [String: Any]?) {
        self.synchronizationQueue.async {
            self.handleEvent(name: name, parameters: parameters)
        }
    }

    // MARK: Private API

    private func handleEvent(name: String, parameters: [String: Any]?) {
        guard let parameters = parameters else {
            return
        }

        self.lock.lock()
        defer { self.lock.unlock() }

        let event = AnalyticsEvent(name: name, parameters: parameters)
        self.queue.enqueue(event)

        self.sendEventsIfNeeded()
    }

    private func sendEventsIfNeeded() {
        if self.hasOngoingRequest {
            return
        }

        self.lock.lock()
        defer { self.lock.unlock() }

        guard self.queue.count >= Self.batchSize else {
            return
        }

        var queueCopy = self.queue
        var events = [AnalyticsEvent]()

        for _ in 0..<Self.batchSize {
            if let event = queueCopy.dequeue() {
                events.append(event)
            } else {
                break
            }
        }

        self.sendEvents(events)
    }

    private func sendEvents(_ events: [AnalyticsEvent]) {
        if self.hasOngoingRequest {
            return
        }

        self.hasOngoingRequest = true
        let metrics = events.map { $0.parameters.require() }

        self.stepikMetricsNetworkService.sendBatchMetrics(metrics).done {
            self.lock.lock()
            defer { self.lock.unlock() }

            for _ in 0..<metrics.count {
                _ = self.queue.dequeue()
            }

            self.hasOngoingRequest = false
            self.sendEventsIfNeeded()
        }.catch { _ in
            self.hasOngoingRequest = false
            print("StepikAnalyticsEngine :: failed send batch metrics")
        }
    }
}
