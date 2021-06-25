import Foundation
import PromiseKit

protocol CourseRevenueInteractorProtocol {
    func doCourseRevenueLoad(request: CourseRevenue.CourseRevenueLoad.Request)
    func doSubmodulesRegistration(request: CourseRevenue.SubmoduleRegistration.Request)
    func doCourseSummaryClickAction(request: CourseRevenue.CourseSummaryClickAction.Request)
}

final class CourseRevenueInteractor: CourseRevenueInteractorProtocol {
    private let presenter: CourseRevenuePresenterProtocol
    private let provider: CourseRevenueProviderProtocol

    private let courseID: Course.IdType
    private var currentCourse: Course? {
        didSet {
            self.pushCurrentCourseToSubmodules(submodules: Array(self.submodules.values))
        }
    }

    // Tab index -> Submodule
    private var submodules: [Int: CourseRevenueSubmoduleProtocol] = [:]

    private let analytics: Analytics
    private var shouldOpenedAnalyticsEventSend = true

    init(
        courseID: Course.IdType,
        presenter: CourseRevenuePresenterProtocol,
        provider: CourseRevenueProviderProtocol,
        analytics: Analytics
    ) {
        self.courseID = courseID
        self.presenter = presenter
        self.provider = provider
        self.analytics = analytics
    }

    func doCourseRevenueLoad(request: CourseRevenue.CourseRevenueLoad.Request) {
        self.provider.fetchCourseAndBenefitSummary().done { fetchResult in
            self.currentCourse = fetchResult.value

            let benefitSummary = self.currentCourse?.courseBenefitSummaries.first(where: { $0.id == self.courseID })
            self.presenter.presentCourseRevenue(
                response: .init(result: .success(.init(courseBenefitSummary: benefitSummary)))
            )

            self.sendOpenedAnalyticsEventIfNeeded()
        }.catch { error in
            print("CourseRevenueInteractor :: error = \(error)")
            self.presenter.presentCourseRevenue(response: .init(result: .failure(error)))
        }
    }

    func doSubmodulesRegistration(request: CourseRevenue.SubmoduleRegistration.Request) {
        for (key, value) in request.submodules {
            self.submodules[key] = value
        }
        self.pushCurrentCourseToSubmodules(submodules: Array(self.submodules.values))
    }

    func doCourseSummaryClickAction(request: CourseRevenue.CourseSummaryClickAction.Request) {
        if let currentCourse = self.currentCourse {
            self.analytics.send(
                .courseBenefitsSummaryClicked(
                    id: currentCourse.id,
                    title: currentCourse.title,
                    expanded: request.expanded
                )
            )
        }
    }

    // MARK: Private API

    private func pushCurrentCourseToSubmodules(submodules: [CourseRevenueSubmoduleProtocol]) {
        if let course = self.currentCourse {
            submodules.forEach { $0.update(with: course) }
        }
    }

    private func sendOpenedAnalyticsEventIfNeeded() {
        guard self.shouldOpenedAnalyticsEventSend,
              let currentCourse = self.currentCourse else {
            return
        }

        self.shouldOpenedAnalyticsEventSend = false
        self.analytics.send(.courseBenefitsScreenOpened(id: currentCourse.id, title: currentCourse.title))
    }
}

extension CourseRevenueInteractor: CourseRevenueTabPurchasesOutputProtocol {
    func handleCourseRevenueTabPurchasesDidRequestPresentCourseInfo(courseID: Course.IdType) {
        self.presenter.presentCourseInfo(response: .init(courseID: courseID))
    }

    func handleCourseRevenueTabPurchasesDidRequestPresentUser(userID: User.IdType) {
        self.presenter.presentProfile(response: .init(userID: userID))
    }
}
