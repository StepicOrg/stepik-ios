import Foundation

protocol VisitedCoursesCleanerProtocol: AnyObject {
    func clear()
    func addObserves()
    func removeObservers()
}

final class VisitedCoursesCleaner: VisitedCoursesCleanerProtocol {
    private let visitedCourseListPersistenceService: VisitedCourseListPersistenceServiceProtocol
    private let dataBackUpdateService: DataBackUpdateServiceProtocol
    private let notificationCenter: NotificationCenter

    init(
        visitedCourseListPersistenceService: VisitedCourseListPersistenceServiceProtocol,
        dataBackUpdateService: DataBackUpdateServiceProtocol,
        notificationCenter: NotificationCenter
    ) {
        self.visitedCourseListPersistenceService = visitedCourseListPersistenceService
        self.dataBackUpdateService = dataBackUpdateService
        self.notificationCenter = notificationCenter
    }

    convenience init() {
        let visitedCourseListPersistenceService = CourseListServicesFactory(
            type: VisitedCourseListType()
        ).makePersistenceService() as? VisitedCourseListPersistenceServiceProtocol

        let dataBackUpdateService = DataBackUpdateService(
            unitsNetworkService: UnitsNetworkService(unitsAPI: UnitsAPI()),
            sectionsNetworkService: SectionsNetworkService(sectionsAPI: SectionsAPI()),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI())
        )

        self.init(
            visitedCourseListPersistenceService: visitedCourseListPersistenceService.require(),
            dataBackUpdateService: dataBackUpdateService,
            notificationCenter: .default
        )
    }

    func addObserves() {
        self.notificationCenter.addObserver(
            self,
            selector: #selector(self.handleDidLoginOrLogout),
            name: .didLogin,
            object: nil
        )
        self.notificationCenter.addObserver(
            self,
            selector: #selector(self.handleDidLoginOrLogout),
            name: .didLogout,
            object: nil
        )
    }

    func removeObservers() {
        self.notificationCenter.removeObserver(self)
    }

    func clear() {
        self.visitedCourseListPersistenceService.update(newCachedList: [])
        self.dataBackUpdateService.triggerVisitedCourseListUpdate()
    }

    @objc
    private func handleDidLoginOrLogout() {
        self.clear()
    }
}
