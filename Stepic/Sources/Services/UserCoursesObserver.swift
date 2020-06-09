import Foundation

protocol UserCoursesObserverProtocol: AnyObject {
    func startObserving()
    func stopObserving()
}

final class UserCoursesObserver: UserCoursesObserverProtocol {
    private let dataBackUpdateService: DataBackUpdateServiceProtocol

    init(
        dataBackUpdateService: DataBackUpdateServiceProtocol = DataBackUpdateService(
            unitsNetworkService: UnitsNetworkService(unitsAPI: UnitsAPI()),
            sectionsNetworkService: SectionsNetworkService(sectionsAPI: SectionsAPI()),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI())
        )
    ) {
        self.dataBackUpdateService = dataBackUpdateService
    }

    func startObserving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleNotification(_:)),
            name: .userCourseDidChangeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleNotification(_:)),
            name: .userCourseDidCreateNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleNotification(_:)),
            name: .userCourseDidDeleteNotification,
            object: nil
        )
    }

    func stopObserving() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func handleNotification(_ notification: Foundation.Notification) {
        guard let targetUserCourse = notification.object as? UserCourse else {
            return
        }

        self.dataBackUpdateService.triggerUserCourseUpdate(updatedUserCourse: targetUserCourse)
    }
}
