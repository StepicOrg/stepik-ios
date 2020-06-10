import Foundation

protocol UserCoursesObserverProtocol: AnyObject {
    func startObserving()
    func stopObserving()
}

final class UserCoursesObserver: UserCoursesObserverProtocol {
    private let dataBackUpdateService: DataBackUpdateServiceProtocol
    private let debouncer: DebouncerProtocol

    private var updatedUserCoursesMap: [Course.IdType: UserCourse] = [:]

    private let synchronizationQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.UserCoursesObserverQueue",
        qos: .background
    )
    private let semaphore = DispatchSemaphore(value: 1)

    init(
        dataBackUpdateService: DataBackUpdateServiceProtocol = DataBackUpdateService(
            unitsNetworkService: UnitsNetworkService(unitsAPI: UnitsAPI()),
            sectionsNetworkService: SectionsNetworkService(sectionsAPI: SectionsAPI()),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI())
        ),
        debouncer: DebouncerProtocol = Debouncer()
    ) {
        self.dataBackUpdateService = dataBackUpdateService
        self.debouncer = debouncer
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

        self.synchronizationQueue.async {
            self.semaphore.wait()

            self.updatedUserCoursesMap[targetUserCourse.courseID] = targetUserCourse

            DispatchQueue.main.async {
                self.debouncer.action = { [weak self] in
                    self?.triggerUserCoursesUpdate()
                }
                self.semaphore.signal()
            }
        }
    }

    private func triggerUserCoursesUpdate() {
        self.synchronizationQueue.async {
            self.semaphore.wait()

            for updatedUserCourse in Array(self.updatedUserCoursesMap.values) {
                DispatchQueue.main.async {
                    self.dataBackUpdateService.triggerUserCourseUpdate(updatedUserCourse: updatedUserCourse)
                }
            }

            self.updatedUserCoursesMap.removeAll(keepingCapacity: true)

            self.semaphore.signal()
        }
    }
}
