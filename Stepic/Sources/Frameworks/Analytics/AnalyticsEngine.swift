import Amplitude_iOS
import FirebaseAnalytics
import Foundation
import YandexMobileMetrica

protocol AnalyticsEngine: AnyObject {
    func sendAnalyticsEvent(named name: String, parameters: [String: Any]?, forceSend: Bool)
}

extension AnalyticsEngine {
    func sendAnalyticsEvent(named name: String) {
        self.sendAnalyticsEvent(named: name, parameters: nil, forceSend: false)
    }
}

// MARK: - AmplitudeAnalyticsEngine: AnalyticsEngine -

final class AmplitudeAnalyticsEngine: AnalyticsEngine {
    private let instance: Amplitude

    init(instance: Amplitude = Amplitude.instance()) {
        self.instance = instance
    }

    func sendAnalyticsEvent(named name: String, parameters: [String: Any]?, forceSend: Bool) {
        self.instance.logEvent(name, withEventProperties: parameters)
        print("Logging Amplitude event: \(name), parameters: \(String(describing: parameters)))")
    }
}

// MARK: - FirebaseAnalyticsEngine: AnalyticsEngine -

final class FirebaseAnalyticsEngine: AnalyticsEngine {
    init() {}

    func sendAnalyticsEvent(named name: String, parameters: [String: Any]?, forceSend: Bool) {
        FirebaseAnalytics.Analytics.logEvent(name, parameters: parameters)
        print("Logging Firebase event: \(name), parameters: \(String(describing: parameters))")
    }
}

// MARK: - AppMetricaAnalyticsEngine: AnalyticsEngine -

final class AppMetricaAnalyticsEngine: AnalyticsEngine {
    init() {}

    func sendAnalyticsEvent(named name: String, parameters: [String: Any]?, forceSend: Bool) {
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

        self.deserializeQueueState()
        self.listenForChangesInNetworkReachabilityStatus()
    }

    // MARK: Protocol Conforming

    func sendAnalyticsEvent(named name: String, parameters: [String: Any]?, forceSend: Bool) {
        self.synchronizationQueue.async {
            self.handleEvent(name: name, parameters: parameters, forceSend: forceSend)
        }
    }

    // MARK: Private API

    private func handleEvent(name: String, parameters: [String: Any]?, forceSend: Bool) {
        guard let parameters = parameters else {
            return
        }

        self.lock.lock()
        defer { self.lock.unlock() }

        let event = AnalyticsEvent(name: name, parameters: parameters)
        self.queue.enqueue(event)

        self.serializeQueueState()
        self.sendEventsIfNeeded(forceSend: forceSend)
    }

    private func sendEventsIfNeeded(forceSend: Bool = false) {
        self.synchronizationQueue.async {
            self.requestSemaphore.wait()

            self.lock.lock()
            defer { self.lock.unlock() }

            let shouldSendEvents = self.queue.count >= Self.batchSize || forceSend
            guard shouldSendEvents else {
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

            self.serializeQueueState()
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

    // MARK: Persistence

    private func serializeQueueState() {
        self.synchronizationQueue.async {
            self.lock.lock()
            defer { self.lock.unlock() }

            do {
                var queueCopy = self.queue
                var events = [AnalyticsEvent]()

                for _ in 0..<queueCopy.count {
                    if let event = queueCopy.dequeue() {
                        events.append(event)
                    } else {
                        break
                    }
                }

                let encodedData = try JSONEncoder().encode(events)
                let fileURL = self.getQueueFileURL()

                try encodedData.write(to: fileURL, options: .atomic)
            } catch {
                print("StepikAnalyticsEngine :: failed serialize queue state with error = \(error)")
            }
        }
    }

    private func deserializeQueueState() {
        let fileURL = self.getQueueFileURL()

        guard let data = try? Data(contentsOf: fileURL) else {
            return
        }

        do {
            let events = try JSONDecoder().decode([AnalyticsEvent].self, from: data)
            for event in events {
                self.queue.enqueue(event)
            }
        } catch {
            print("StepikAnalyticsEngine :: failed deserialize queue state with error = \(error)")
        }
    }

    private func getQueueFileURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory.appendingPathComponent("StepikAnalyticsEngineQueueState.txt")
    }
}
