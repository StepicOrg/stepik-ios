import Amplitude
import AppMetricaCore
import FirebaseAnalytics
import Foundation

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

        if LaunchArguments.analyticsDebugEnabled {
            print("Logging Amplitude event: \(name), parameters: \(String(describing: parameters)))")
        }
    }
}

// MARK: - FirebaseAnalyticsEngine: AnalyticsEngine -

final class FirebaseAnalyticsEngine: AnalyticsEngine {
    init() {}

    func sendAnalyticsEvent(named name: String, parameters: [String: Any]?, forceSend: Bool) {
        guard name != "Course card seen" else {
            return
        }

        let processedName = self.processString(name)
        let processedParameters: [String: Any]? = {
            guard let parameters = parameters else {
                return nil
            }

            return Dictionary(uniqueKeysWithValues: parameters.map { (self.processString($0), $1) })
        }()

        FirebaseAnalytics.Analytics.logEvent(processedName, parameters: processedParameters)

        if LaunchArguments.analyticsDebugEnabled {
            print("Logging Firebase event: \(processedName), parameters: \(String(describing: processedParameters))")
        }
    }

    private func processString(_ string: String) -> String {
        guard string.containsWhitespace else {
            return string
        }

        return string
            .replacingOccurrences(of: " ", with: "_")
            .lowercased()
    }
}

// MARK: - AppMetricaAnalyticsEngine: AnalyticsEngine -

final class AppMetricaAnalyticsEngine: AnalyticsEngine {
    init() {}

    func sendAnalyticsEvent(named name: String, parameters: [String: Any]?, forceSend: Bool) {
        AppMetrica.reportEvent(name: name, parameters: parameters) { error in
            if LaunchArguments.analyticsDebugEnabled {
                print(
                    """
                    ERROR Logging AppMetrica event: \(name), parameters: \(String(describing: parameters)), \
                    error = \(error)
                    """
                )
            }
        }

        if LaunchArguments.analyticsDebugEnabled {
            print("Logging AppMetrica event: \(name), parameters: \(String(describing: parameters))")
        }
    }
}

// MARK: - StepikAnalyticsEngine: AnalyticsEngine -

final class StepikAnalyticsEngine: AnalyticsEngine {
    private static let batchSize = 30

    private let stepikMetricsNetworkService: StepikMetricsNetworkServiceProtocol
    private let networkReachabilityService: NetworkReachabilityServiceProtocol

    private var queue = Queue<JSONDictionary>()

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

            if LaunchArguments.analyticsDebugEnabled {
                print("Logging Stepik event: \(name), parameters: \(String(describing: parameters))")
            }
        }
    }

    // MARK: Private API

    private func handleEvent(name: String, parameters: [String: Any]?, forceSend: Bool) {
        guard let eventParameters = parameters else {
            return
        }

        self.lock.lock()
        defer { self.lock.unlock() }

        self.queue.enqueue(eventParameters)

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
            var events = [JSONDictionary]()

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

    private func sendEvents(_ events: [JSONDictionary]) {
        self.stepikMetricsNetworkService.sendBatchMetrics(events).done {
            self.lock.lock()
            defer { self.lock.unlock() }

            for _ in 0..<events.count {
                _ = self.queue.dequeue()
            }

            self.serializeQueueState()
            self.sendEventsIfNeeded()

            if LaunchArguments.analyticsDebugEnabled {
                print("StepikAnalyticsEngine :: done send batch metrics")
            }
        }.ensure {
            self.requestSemaphore.signal()
        }.catch { error in
            if LaunchArguments.analyticsDebugEnabled {
                print("StepikAnalyticsEngine :: failed send batch metrics with error = \(error)")
            }
        }
    }

    private func listenForChangesInNetworkReachabilityStatus() {
        self.networkReachabilityService.startListening { networkReachabilityStatus in
            if networkReachabilityStatus == .reachable {
                self.sendEventsIfNeeded()
            }
        }
    }

    // MARK: Persistence

    private func serializeQueueState() {
        self.synchronizationQueue.async {
            do {
                var queueCopy = self.queue
                var events = [JSONDictionary]()

                for _ in 0..<queueCopy.count {
                    if let event = queueCopy.dequeue() {
                        events.append(event)
                    } else {
                        break
                    }
                }

                let encodedData = try JSONSerialization.data(withJSONObject: events, options: [])
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
            guard let events = try JSONSerialization.jsonObject(with: data, options: []) as? [JSONDictionary] else {
                return print("StepikAnalyticsEngine :: failed deserialize queue state")
            }

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
