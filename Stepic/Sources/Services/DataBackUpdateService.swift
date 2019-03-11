import Foundation
import PromiseKit

enum DataBackUpdateTarget {
    case course(_: Course)
    case section(_: Section)
    case unit(_: Unit)
    case progress(_: Progress)
}

struct DataBackUpdateDescription: OptionSet {
    let rawValue: Int

    static let progress = DataBackUpdateDescription(rawValue: 1)
    static let enrollment = DataBackUpdateDescription(rawValue: 2)
}

protocol DataBackUpdateServiceDelegate: class {
    func dataBackUpdateService(
        _ dataBackUpdateService: DataBackUpdateService,
        reportUpdate update: DataBackUpdateDescription,
        for target: DataBackUpdateTarget
    )

    func dataBackUpdateService(
        _ dataBackUpdateService: DataBackUpdateService,
        reportRefreshedTarget: DataBackUpdateTarget
    )
}

extension DataBackUpdateServiceDelegate {
    func dataBackUpdateService(
        _ dataBackUpdateService: DataBackUpdateService,
        reportUpdate update: DataBackUpdateDescription,
        for target: DataBackUpdateTarget
    ) { }

    func dataBackUpdateService(
        _ dataBackUpdateService: DataBackUpdateService,
        reportRefreshedTarget: DataBackUpdateTarget
    ) { }
}

protocol DataBackUpdateServiceProtocol: class {
    var delegate: DataBackUpdateServiceDelegate? { get set }

    /// Report about unit progress update
    func triggerProgressUpdate(unit: Unit.IdType, triggerRecursive: Bool)
    /// Report about section progress update
    func triggerProgressUpdate(section: Section.IdType, triggerRecursive: Bool)
    /// Report about course progress update
    func triggerProgressUpdate(course: Course.IdType)
    /// Report about enrollment with already retrieved course
    func triggerEnrollmentUpdate(retrievedCourse: Course)
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
            CoreDataHelper.instance.save()

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
            CoreDataHelper.instance.save()

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
            CoreDataHelper.instance.save()

            strongSelf.postNotification(target: .progress(progress))
            strongSelf.postNotification(description: .progress, target: .course(course))
        }.cauterize()
    }

    func triggerEnrollmentUpdate(retrievedCourse: Course) {
        self.postNotification(description: [.enrollment], target: .course(retrievedCourse))
        self.postNotification(target: .course(retrievedCourse))
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
            self.delegate?.dataBackUpdateService(self, reportRefreshedTarget: updateTarget)
            return
        }

        let descriptionFromUserInfo = notification.userInfo?[NotificationKey.description]
        guard let updateDescription = descriptionFromUserInfo as? DataBackUpdateDescription else {
            print("data back update service: received malformed notification")
            return
        }

        self.delegate?.dataBackUpdateService(self, reportUpdate: updateDescription, for: updateTarget)
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
