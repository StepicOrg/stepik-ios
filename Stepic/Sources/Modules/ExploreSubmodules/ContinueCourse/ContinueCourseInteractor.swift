import Foundation
import PromiseKit

protocol ContinueCourseInteractorProtocol {
    func doLastCourseRefresh(request: ContinueCourse.LastCourseLoad.Request)
    func doContinueLastCourseAction(request: ContinueCourse.ContinueCourseAction.Request)
    func doTooltipAvailabilityCheck(request: ContinueCourse.TooltipAvailabilityCheck.Request)
}

final class ContinueCourseInteractor: ContinueCourseInteractorProtocol {
    weak var moduleOutput: ContinueCourseOutputProtocol?

    private let presenter: ContinueCoursePresenterProtocol
    private let provider: ContinueCourseProviderProtocol
    private let adaptiveStorageManager: AdaptiveStorageManagerProtocol
    private let tooltipStorageManager: TooltipStorageManagerProtocol
    private let dataBackUpdateService: DataBackUpdateServiceProtocol

    private var currentCourse: Course?

    init(
        presenter: ContinueCoursePresenterProtocol,
        provider: ContinueCourseProviderProtocol,
        adaptiveStorageManager: AdaptiveStorageManagerProtocol,
        tooltipStorageManager: TooltipStorageManagerProtocol,
        dataBackUpdateService: DataBackUpdateServiceProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
        self.adaptiveStorageManager = adaptiveStorageManager
        self.tooltipStorageManager = tooltipStorageManager

        self.dataBackUpdateService = dataBackUpdateService
        self.dataBackUpdateService.delegate = self
    }

    func doLastCourseRefresh(request: ContinueCourse.LastCourseLoad.Request) {
        self.provider.fetchLastCourse().done { course in
            if let course = course {
                self.currentCourse = course
                self.presenter.presentLastCourse(response: .init(result: course))
            } else {
                self.moduleOutput?.hideContinueCourse()
            }
        }.catch { _ in
            self.moduleOutput?.hideContinueCourse()
        }
    }

    func doContinueLastCourseAction(request: ContinueCourse.ContinueCourseAction.Request) {
        guard let currentCourse = self.currentCourse else {
            return
        }

        let isAdaptive = self.adaptiveStorageManager.canOpenInAdaptiveMode(
            courseId: currentCourse.id
        )

        // FIXME: analytics dependency
        AmplitudeAnalyticsEvents.Course.continuePressed(
            source: "home_widget",
            courseID: currentCourse.id,
            courseTitle: currentCourse.title
        ).send()

        self.moduleOutput?.presentLastStep(
            course: currentCourse,
            isAdaptive: isAdaptive
        )
    }

    func doTooltipAvailabilityCheck(request: ContinueCourse.TooltipAvailabilityCheck.Request) {
        self.presenter.presentTooltip(
            response: .init(
                shouldShowTooltip: !self.tooltipStorageManager.didShowOnHomeContinueLearning
            )
        )
        self.tooltipStorageManager.didShowOnHomeContinueLearning = true
    }
}

extension ContinueCourseInteractor: DataBackUpdateServiceDelegate {
    func dataBackUpdateService(
        _ dataBackUpdateService: DataBackUpdateService,
        reportUpdate update: DataBackUpdateDescription,
        for target: DataBackUpdateTarget
    ) {
        guard case .course(let course) = target,
              course.id == self.currentCourse?.id else {
            return
        }

        self.currentCourse = course
        self.presenter.presentLastCourse(response: .init(result: course))
    }
}
