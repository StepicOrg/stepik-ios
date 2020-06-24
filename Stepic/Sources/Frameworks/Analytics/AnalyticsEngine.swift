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
    private let networkReachabilityService: NetworkReachabilityServiceProtocol

    private var queue = Queue<AnalyticsEvent>()

    private let synchronizationQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.StepikAnalyticsEngine",
        qos: .background
    )
    // TODO: Replace with pthread_mutex_t
    private let lock = NSLock()

    private let requestSemaphore = DispatchSemaphore(value: 1)

    init(
        stepikMetricsNetworkService: StepikMetricsNetworkServiceProtocol = StepikMetricsNetworkService(),
        networkReachabilityService: NetworkReachabilityServiceProtocol = NetworkReachabilityService()
    ) {
        self.stepikMetricsNetworkService = stepikMetricsNetworkService
        self.networkReachabilityService = networkReachabilityService

        self.listenForChangesInNetworkReachabilityStatus()
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
        self.synchronizationQueue.async {
            self.requestSemaphore.wait()

            self.lock.lock()
            defer { self.lock.unlock() }

            guard self.queue.count >= Self.batchSize else {
                self.requestSemaphore.signal()
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
    }

    private func sendEvents(_ events: [AnalyticsEvent]) {
        let batchMetrics = events.map { $0.parameters.require() }

        self.stepikMetricsNetworkService.sendBatchMetrics(batchMetrics).done {
            self.lock.lock()
            defer { self.lock.unlock() }

            for _ in 0..<batchMetrics.count {
                _ = self.queue.dequeue()
            }

            self.sendEventsIfNeeded()
        }.ensure {
            self.requestSemaphore.signal()
        }.catch { _ in
            print("StepikAnalyticsEngine :: failed send batch metrics")
        }
    }

    private func listenForChangesInNetworkReachabilityStatus() {
        self.networkReachabilityService.startListening { networkReachabilityStatus in
            self.synchronizationQueue.async {
                if networkReachabilityStatus == .reachable {
                    self.sendEventsIfNeeded()
                }
            }
        }
    }
}
