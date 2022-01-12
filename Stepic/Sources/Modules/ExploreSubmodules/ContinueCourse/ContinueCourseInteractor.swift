import Foundation
import PromiseKit

protocol ContinueCourseInteractorProtocol {
    func doLastCourseRefresh(request: ContinueCourse.LastCourseLoad.Request)
    func doContinueLastCourseAction(request: ContinueCourse.ContinueCourseAction.Request)
    func doContinueCourseEmptyAction(request: ContinueCourse.ContinueCourseEmptyAction.Request)
    func doTooltipAvailabilityCheck(request: ContinueCourse.TooltipAvailabilityCheck.Request)
    func doSiriButtonAvailabilityCheck(request: ContinueCourse.SiriButtonAvailabilityCheck.Request)
    func doSiriButtonAction(request: ContinueCourse.SiriButtonAction.Request)
}

final class ContinueCourseInteractor: ContinueCourseInteractorProtocol {
    private static let siriButtonAvailabilityCheckDelay: TimeInterval = 1

    weak var moduleOutput: ContinueCourseOutputProtocol?

    private let presenter: ContinueCoursePresenterProtocol
    private let provider: ContinueCourseProviderProtocol
    private let analytics: Analytics
    private let adaptiveStorageManager: AdaptiveStorageManagerProtocol
    private let tooltipStorageManager: TooltipStorageManagerProtocol
    private let dataBackUpdateService: DataBackUpdateServiceProtocol

    @available(iOS 12.0, *)
    private lazy var siriShortcutsService: SiriShortcutsServiceProtocol = SiriShortcutsService()
    @available(iOS 12.0, *)
    private lazy var siriShortcutsStorageManager: SiriShortcutsStorageManagerProtocol = SiriShortcutsStorageManager()

    private var currentCourse: Course?

    init(
        presenter: ContinueCoursePresenterProtocol,
        provider: ContinueCourseProviderProtocol,
        analytics: Analytics,
        adaptiveStorageManager: AdaptiveStorageManagerProtocol,
        tooltipStorageManager: TooltipStorageManagerProtocol,
        dataBackUpdateService: DataBackUpdateServiceProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
        self.analytics = analytics
        self.adaptiveStorageManager = adaptiveStorageManager
        self.tooltipStorageManager = tooltipStorageManager

        self.dataBackUpdateService = dataBackUpdateService
        self.dataBackUpdateService.delegate = self
    }

    func doLastCourseRefresh(request: ContinueCourse.LastCourseLoad.Request) {
        self.provider.fetchLastCourse().done { course in
            if let course = course {
                self.currentCourse = course
                self.presenter.presentLastCourse(response: .init(result: .success(course)))
            } else {
                self.presenter.presentLastCourse(response: .init(result: .failure(Error.noLastCourse)))
            }
        }.catch { _ in
            if self.currentCourse == nil {
                self.moduleOutput?.hideContinueCourse()
            }
        }
    }

    func doContinueLastCourseAction(request: ContinueCourse.ContinueCourseAction.Request) {
        guard let currentCourse = self.currentCourse else {
            return
        }

        let isAdaptive = self.adaptiveStorageManager.canOpenInAdaptiveMode(courseId: currentCourse.id)

        self.moduleOutput?.presentLastStep(
            course: currentCourse,
            isAdaptive: isAdaptive,
            source: .homeWidget,
            viewSource: .fastContinue
        )

        if #available(iOS 12.0, *) {
            self.siriShortcutsStorageManager.didClickFastContinueOnHomeWidget = true

            DispatchQueue.main.asyncAfter(deadline: .now() + Self.siriButtonAvailabilityCheckDelay) {
                self.doSiriButtonAvailabilityCheck(request: .init())
            }
        }
    }

    func doContinueCourseEmptyAction(request: ContinueCourse.ContinueCourseEmptyAction.Request) {
        self.moduleOutput?.presentCatalog()
    }

    func doTooltipAvailabilityCheck(request: ContinueCourse.TooltipAvailabilityCheck.Request) {
        self.presenter.presentTooltip(
            response: .init(
                shouldShowTooltip: !self.tooltipStorageManager.didShowOnHomeContinueLearning
            )
        )
        self.tooltipStorageManager.didShowOnHomeContinueLearning = true
    }

    func doSiriButtonAvailabilityCheck(request: ContinueCourse.SiriButtonAvailabilityCheck.Request) {
        if #available(iOS 12.0, *),
           self.siriShortcutsStorageManager.shouldShowSiriButtonOnHomeWidget {
            let userActivity = self.siriShortcutsService.getContinueLearningShortcut()
            self.presenter.presentSiriButton(response: .init(shouldShowButton: true, userActivity: userActivity))
        } else {
            self.presenter.presentSiriButton(response: .init(shouldShowButton: false))
        }
    }

    func doSiriButtonAction(request: ContinueCourse.SiriButtonAction.Request) {
        if #available(iOS 12.0, *) {
            self.siriShortcutsStorageManager.didClickAddToSiriOnHomeWidget = true
        }
    }

    enum Error: Swift.Error {
        case noLastCourse
    }
}

extension ContinueCourseInteractor: DataBackUpdateServiceDelegate {
    func dataBackUpdateService(
        _ dataBackUpdateService: DataBackUpdateService,
        didReport update: DataBackUpdateDescription,
        for target: DataBackUpdateTarget
    ) {
        guard case .course(let course) = target,
              course.id == self.currentCourse?.id else {
            return
        }

        self.currentCourse = course
        self.presenter.presentLastCourse(response: .init(result: .success(course)))
    }

    func dataBackUpdateService(
        _ dataBackUpdateService: DataBackUpdateService,
        didReport refreshedTarget: DataBackUpdateTarget
    ) {}
}
