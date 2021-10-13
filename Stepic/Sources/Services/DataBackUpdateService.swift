import Foundation
import PromiseKit

/// Which object was updated
enum DataBackUpdateTarget {
    case course(Course)
    case section(Section)
    case unit(Unit)
    case progress(Progress)
    case profile(Profile)
    case userCourse(UserCourse)
    case visitedCourse
    case wishlist([Course.IdType])
    case downloads
}

/// Affected fields in updated object
struct DataBackUpdateDescription: OptionSet {
    let rawValue: Int

    static let progress = DataBackUpdateDescription(rawValue: 1 << 0)
    static let enrollment = DataBackUpdateDescription(rawValue: 1 << 1)
    static let profileFirstName = DataBackUpdateDescription(rawValue: 1 << 2)
    static let profileLastName = DataBackUpdateDescription(rawValue: 1 << 3)
    static let profileShortBio = DataBackUpdateDescription(rawValue: 1 << 4)
    static let profileDetails = DataBackUpdateDescription(rawValue: 1 << 5)
    static let courseIsFavorite = DataBackUpdateDescription(rawValue: 1 << 6)
    static let courseIsArchived = DataBackUpdateDescription(rawValue: 1 << 7)
}

protocol DataBackUpdateServiceDelegate: AnyObject {
    /// Reported changes in specific fields of target
    func dataBackUpdateService(
        _ dataBackUpdateService: DataBackUpdateService,
        didReport update: DataBackUpdateDescription,
        for target: DataBackUpdateTarget
    )

    /// Reported changes in whole target
    func dataBackUpdateService(
        _ dataBackUpdateService: DataBackUpdateService,
        didReport refreshedTarget: DataBackUpdateTarget
    )
}

protocol DataBackUpdateServiceProtocol: AnyObject {
    var delegate: DataBackUpdateServiceDelegate? { get set }

    /// Report about unit progress update
    func triggerProgressUpdate(unit: Unit.IdType, triggerRecursive: Bool)
    /// Report about section progress update
    func triggerProgressUpdate(section: Section.IdType, triggerRecursive: Bool)
    /// Report about course progress update
    func triggerProgressUpdate(course: Course.IdType)
    /// Report about enrollment with already retrieved course
    func triggerEnrollmentUpdate(retrievedCourse: Course)
    /// Report about profile update
    func triggerProfileUpdate(updatedProfile: Profile)
    /// Report about `isFavorite` state update with already retrieved course
    func triggerCourseIsFavoriteUpdate(retrievedCourse: Course)
    /// Report about `isArchived` state update with already retrieved course
    func triggerCourseIsArchivedUpdate(retrievedCourse: Course)
    /// Report about user course update
    func triggerUserCourseUpdate(updatedUserCourse: UserCourse)
    /// Report about visited course list update
    func triggerVisitedCourseListUpdate()
    /// Report about wishlist update
    func triggerWishlistUpdate(coursesIDs: [Course.IdType])
    /// Report about downloads update
    func triggerDownloadsUpdated()
}

final class DataBackUpdateService: DataBackUpdateServiceProtocol {
    weak var delegate: DataBackUpdateServiceDelegate?

    private let unitsNetworkService: UnitsNetworkServiceProtocol
    private let sectionsNetworkService: SectionsNetworkServiceProtocol
    private let coursesNetworkService: CoursesNetworkServiceProtocol
    private let progressesNetworkService: ProgressesNetworkServiceProtocol

    init(
        unitsNetworkService: UnitsNetworkServiceProtocol,
        sectionsNetworkService: SectionsNetworkServiceProtocol,
        coursesNetworkService: CoursesNetworkServiceProtocol,
        progressesNetworkService: ProgressesNetworkServiceProtocol
    ) {
        self.unitsNetworkService = unitsNetworkService
        self.sectionsNetworkService = sectionsNetworkService
        self.coursesNetworkService = coursesNetworkService
        self.progressesNetworkService = progressesNetworkService

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleNotification(_:)),
            name: .dataBackUpdated,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleNotification(_:)),
            name: .dataBackUpdatedWithDescription,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Public methods

    func triggerProgressUpdate(unit: Unit.IdType, triggerRecursive: Bool = true) {
        self.unitsNetworkService.fetch(ids: [unit]).then { units -> Promise<(Unit, Progress?)> in
            guard let unit = units.first,
                  let progressID = unit.progressId else {
                throw Error.fetchFailed
            }

            return self.progressesNetworkService.fetch(id: progressID).map { (unit, $0) }
        }.done { [weak self] unit, progress in
            guard let strongSelf = self,
                  let progress = progress else {
                return
            }

            unit.progress = progress
            CoreDataHelper.shared.save()

            strongSelf.postNotification(target: .progress(progress))
            strongSelf.postNotification(description: .progress, target: .unit(unit))

            if triggerRecursive {
                strongSelf.triggerProgressUpdate(section: unit.sectionId, triggerRecursive: true)
            }
        }.cauterize()
    }

    func triggerProgressUpdate(section: Section.IdType, triggerRecursive: Bool = true) {
        self.sectionsNetworkService.fetch(ids: [section]).then { sections -> Promise<(Section, Progress?)> in
            guard let section = sections.first,
                  let progressID = section.progressId else {
                throw Error.fetchFailed
            }

            return self.progressesNetworkService.fetch(id: progressID).map { (section, $0) }
        }.done { [weak self] section, progress in
            guard let strongSelf = self,
                  let progress = progress else {
                return
            }

            section.progress = progress
            CoreDataHelper.shared.save()

            strongSelf.postNotification(target: .progress(progress))
            strongSelf.postNotification(description: .progress, target: .section(section))

            if triggerRecursive {
                strongSelf.triggerProgressUpdate(course: section.courseId)
            }
        }.cauterize()
    }

    func triggerProgressUpdate(course: Course.IdType) {
        self.coursesNetworkService.fetch(id: course).then { course -> Promise<(Course, Progress?)> in
            guard let course = course,
                  let progressID = course.progressId else {
                throw Error.fetchFailed
            }

            return self.progressesNetworkService.fetch(id: progressID).map { (course, $0) }
        }.done { [weak self] course, progress in
            guard let strongSelf = self,
                  let progress = progress else {
                return
            }

            course.progress = progress
            CoreDataHelper.shared.save()

            strongSelf.postNotification(target: .progress(progress))
            strongSelf.postNotification(description: .progress, target: .course(course))
        }.cauterize()
    }

    func triggerEnrollmentUpdate(retrievedCourse: Course) {
        self.postNotification(description: [.enrollment], target: .course(retrievedCourse))
        self.postNotification(target: .course(retrievedCourse))
    }

    func triggerProfileUpdate(updatedProfile: Profile) {
        self.postNotification(
            description: [.profileFirstName, .profileLastName, .profileShortBio, .profileDetails],
            target: .profile(updatedProfile)
        )
        self.postNotification(target: .profile(updatedProfile))
    }

    func triggerCourseIsFavoriteUpdate(retrievedCourse: Course) {
        self.postNotification(description: [.courseIsFavorite], target: .course(retrievedCourse))
        self.postNotification(target: .course(retrievedCourse))
    }

    func triggerCourseIsArchivedUpdate(retrievedCourse: Course) {
        self.postNotification(description: [.courseIsArchived], target: .course(retrievedCourse))
        self.postNotification(target: .course(retrievedCourse))
    }

    func triggerUserCourseUpdate(updatedUserCourse: UserCourse) {
        self.postNotification(target: .userCourse(updatedUserCourse))
    }

    func triggerVisitedCourseListUpdate() {
        self.postNotification(target: .visitedCourse)
    }

    func triggerWishlistUpdate(coursesIDs: [Course.IdType]) {
        self.postNotification(target: .wishlist(coursesIDs))
    }

    func triggerDownloadsUpdated() {
        self.postNotification(target: .downloads)
    }

    // MARK: Private methods

    private func postNotification(description: DataBackUpdateDescription? = nil, target: DataBackUpdateTarget) {
        if let description = description {
            NotificationCenter.default.post(
                name: .dataBackUpdatedWithDescription,
                object: self,
                userInfo: [
                    NotificationKey.description: description,
                    NotificationKey.target: target
                ]
            )
        } else {
            NotificationCenter.default.post(
                name: .dataBackUpdated,
                object: self,
                userInfo: [NotificationKey.target: target]
            )
        }
    }

    @objc
    private func handleNotification(_ notification: Foundation.Notification) {
        guard let updateTarget = notification.userInfo?[NotificationKey.target] as? DataBackUpdateTarget else {
            print("data back update service: received malformed notification")
            return
        }

        if notification.name == .dataBackUpdated {
            self.delegate?.dataBackUpdateService(self, didReport: updateTarget)
            return
        }

        let descriptionFromUserInfo = notification.userInfo?[NotificationKey.description]
        guard let updateDescription = descriptionFromUserInfo as? DataBackUpdateDescription else {
            print("data back update service: received malformed notification")
            return
        }

        self.delegate?.dataBackUpdateService(self, didReport: updateDescription, for: updateTarget)
    }

    private enum NotificationKey: String {
        case description
        case target
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}

private extension Foundation.Notification.Name {
    static let dataBackUpdated = NSNotification.Name("dataBackUpdated")
    static let dataBackUpdatedWithDescription = NSNotification.Name("dataBackUpdatedWithDescription")
}

extension DataBackUpdateService {
    static var `default`: DataBackUpdateService {
        DataBackUpdateService(
            unitsNetworkService: UnitsNetworkService(unitsAPI: UnitsAPI()),
            sectionsNetworkService: SectionsNetworkService(sectionsAPI: SectionsAPI()),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI())
        )
    }
}
