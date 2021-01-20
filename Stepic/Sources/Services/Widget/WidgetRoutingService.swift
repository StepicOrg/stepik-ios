import Foundation
import PromiseKit

@available(iOS 14.0, *)
protocol WidgetRoutingServiceProtocol: AnyObject {
    func canOpen(url: URL) -> Bool
    func open(url: URL)
}

@available(iOS 14.0, *)
final class WidgetRoutingService: WidgetRoutingServiceProtocol {
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol
    private let adaptiveStorageManager: AdaptiveStorageManagerProtocol
    private let sourcelessRouter: SourcelessRouter
    private let analytics: Analytics

    init(
        coursesPersistenceService: CoursesPersistenceServiceProtocol,
        adaptiveStorageManager: AdaptiveStorageManagerProtocol,
        sourcelessRouter: SourcelessRouter,
        analytics: Analytics
    ) {
        self.coursesPersistenceService = coursesPersistenceService
        self.adaptiveStorageManager = adaptiveStorageManager
        self.sourcelessRouter = sourcelessRouter
        self.analytics = analytics
    }

    func canOpen(url: URL) -> Bool {
        url.host == WidgetConstants.URL.widgetHost
    }

    func open(url: URL) {
        guard self.canOpen(url: url) else {
            return
        }

        var path = url.absoluteString
        path = path.replacingOccurrences(of: WidgetConstants.URL.widgetHost, with: WidgetConstants.URL.host)

        guard let deeplinkRoute = DeepLinkRoute(path: path) else {
            return
        }

        DispatchQueue.main.async {
            self.route(deeplinkRoute)
        }
    }

    private func route(_ deeplinkRoute: DeepLinkRoute) {
        let courseViewSource = AnalyticsEvent.CourseViewSource.widgetExtension(url: deeplinkRoute.path)

        switch deeplinkRoute {
        case .course(let courseID):
            self.coursesPersistenceService.fetch(id: courseID).done { course in
                self.analytics.send(
                    .courseContinuePressed(source: .homeScreenWidget, id: courseID, title: course?.title ?? "")
                )

                guard let course = course,
                      let currentNavigationController = self.sourcelessRouter.currentNavigation else {
                    return
                }

                LastStepRouter.continueLearning(
                    for: course,
                    isAdaptive: self.adaptiveStorageManager.canOpenInAdaptiveMode(courseId: courseID),
                    using: currentNavigationController,
                    courseViewSource: courseViewSource
                )
            }.catch { _ in
                self.analytics.send(.courseContinuePressed(source: .homeScreenWidget, id: courseID, title: ""))
            }
        default:
            self.analytics.send(.homeScreenWidgetClicked)

            let deepLinkRoutingService = DeepLinkRoutingService(courseViewSource: courseViewSource)
            deepLinkRoutingService.route(deeplinkRoute)
        }
    }
}

@available(iOS 14.0, *)
extension WidgetRoutingService {
    static var `default`: WidgetRoutingService {
        WidgetRoutingService(
            coursesPersistenceService: CoursesPersistenceService(),
            adaptiveStorageManager: AdaptiveStorageManager(),
            sourcelessRouter: SourcelessRouter(),
            analytics: StepikAnalytics.shared
        )
    }
}
