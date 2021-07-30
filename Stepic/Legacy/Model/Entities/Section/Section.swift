import CoreData
import SwiftyJSON

@objc
final class Section: NSManagedObject, ManagedObject, IDFetchable {
    typealias IdType = Int

    var isReachable: Bool {
        (self.isActive || self.testSectionAction != nil) && (self.progressId != nil || self.isExam)
    }

    var isCached: Bool {
        get {
            if self.units.isEmpty {
                return false
            }

            for unit in self.units {
                if let lesson = unit.lesson {
                    if !lesson.isCached {
                        return false
                    }
                } else {
                    return false
                }
            }

            return true
        }
    }

    var isStarted: Bool {
        if let effectiveBeginDateSource = self.effectiveBeginDateSource {
            return effectiveBeginDateSource <= Date()
        }
        return false
    }

    var isFinished: Bool {
        if let effectiveEndDateSource = self.effectiveEndDateSource {
            return effectiveEndDateSource < Date()
        }
        return false
    }

    var effectiveBeginDateSource: Date? {
        self.beginDateSource ?? self.course?.beginDateSource
    }

    var effectiveEndDateSource: Date? {
        self.endDateSource ?? self.course?.endDateSource
    }

    var isExamTime: Bool {
        let now = Date()
        let beginDate = self.effectiveBeginDateSource
        let endDate = self.effectiveEndDateSource
        return (beginDate == nil || (beginDate.require() < now)) && (endDate == nil || (now < endDate.require()))
    }

    var isExamCanNotStart: Bool {
        !self.isStarted || self.isFinished
    }

    var isExamCanStart: Bool {
        if !self.isExam {
            return false
        }

        if !self.isReachable {
            return false
        }

        if self.examSession?.id != nil {
            return false
        }

        if self.proctorSession?.isFinished ?? false {
            return false
        }

        if self.testSectionAction != nil {
            return true
        }

        return self.isExamTime && self.isRequirementSatisfied
    }

    var isExamActive: Bool {
        (self.examSession?.isActive ?? false) && !(self.proctorSession?.isFinished ?? false)
    }

    var isExamFinished: Bool {
        if self.isExamCanStart || self.isExamActive {
            return false
        }

        return self.isFinished || (self.proctorSession?.isFinished ?? false) || self.examSession?.id != nil
    }

    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.title = json[JSONKey.title.rawValue].stringValue
        self.position = json[JSONKey.position.rawValue].intValue
        self.isActive = json[JSONKey.isActive.rawValue].boolValue
        self.progressId = json[JSONKey.progress.rawValue].string
        self.unitsArray = json[JSONKey.units.rawValue].arrayObject as! [Int]
        self.courseId = json[JSONKey.course.rawValue].intValue
        self.testSectionAction = json[JSONKey.actions.rawValue][JSONKey.testSection.rawValue].string
        self.discountingPolicy = json[JSONKey.discountingPolicy.rawValue].string
        // Exam
        self.isExam = json[JSONKey.isExam.rawValue].boolValue
        self.examDurationInMinutes = json[JSONKey.examDurationMinutes.rawValue].int
        self.examSessionId = json[JSONKey.examSession.rawValue].int
        self.proctorSessionId = json[JSONKey.proctorSession.rawValue].int
        self.isProctoringCanBeScheduled = json[JSONKey.isProctoringCanBeScheduled.rawValue].boolValue
        // Required section
        self.isRequirementSatisfied = json[JSONKey.isRequirementSatisfied.rawValue].bool ?? true
        self.requiredSectionID = json[JSONKey.requiredSection.rawValue].int
        self.requiredPercent = json[JSONKey.requiredPercent.rawValue].intValue
        // Dates
        self.beginDate = Parser.dateFromTimedateJSON(json[JSONKey.beginDate.rawValue])
        self.endDate = Parser.dateFromTimedateJSON(json[JSONKey.endDate.rawValue])
        self.beginDateSource = Parser.dateFromTimedateJSON(json[JSONKey.beginDateSource.rawValue])
        self.endDateSource = Parser.dateFromTimedateJSON(json[JSONKey.endDateSource.rawValue])
        self.softDeadline = Parser.dateFromTimedateJSON(json[JSONKey.softDeadline.rawValue])
        self.hardDeadline = Parser.dateFromTimedateJSON(json[JSONKey.hardDeadline.rawValue])
    }

    @available(*, deprecated, message: "Legacy")
    static func fetch(_ ids: [IdType]) -> [Section] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Section")
        let idPredicates = ids.map { NSPredicate(format: "managedId == %@", $0 as NSNumber) }
        request.predicate = NSCompoundPredicate(type: .or, subpredicates: idPredicates)

        var sections = [Section]()
        CoreDataHelper.shared.context.performAndWait {
            do {
                sections = try CoreDataHelper.shared.context.fetch(request) as? [Section] ?? []
            } catch {
                sections = []
            }
        }

        return sections
    }

    @available(*, deprecated, message: "Legacy")
    static func getSections(_ id: Int) throws -> [Section] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Section")

        let descriptor = NSSortDescriptor(key: "managedId", ascending: false)
        var predicate = NSPredicate(value: true)

        let p = NSPredicate(format: "managedId == %@", id as NSNumber)
        predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, p])

        request.predicate = predicate
        request.sortDescriptors = [descriptor]

        do {
            let results = try CoreDataHelper.shared.context.fetch(request)
            return results as! [Section]
        } catch {
            throw DatabaseError.fetchFailed
        }
    }

    @available(*, deprecated, message: "Legacy")
    func loadUnits(success: @escaping (() -> Void), error errorHandler: @escaping (() -> Void)) {
        if self.unitsArray.count == 0 {
            success()
            return
        }

        let requestUnitsCount = 50
        var dimCount = 0
        var idsArray = [[Int]]()
        for (index, unitId) in self.unitsArray.enumerated() {
            if index % requestUnitsCount == 0 {
                idsArray.append([Int]())
                dimCount += 1
            }
            idsArray[dimCount - 1].append(unitId)
        }

        var downloadedUnits = [Unit]()

        let idsDownloaded: ([Unit]) -> Void = {
            uns in
            downloadedUnits.append(contentsOf: uns)
            if downloadedUnits.count == self.unitsArray.count {
                self.units = Sorter.sort(downloadedUnits, byIds: self.unitsArray)
                CoreDataHelper.shared.save()
                success()
            }
        }

        var wasError = false
        let errorWhileDownloading: () -> Void = {
            if !wasError {
                wasError = true
                errorHandler()
            }
        }

        for ids in idsArray {
            _ = ApiDataDownloader.units.retrieve(
                ids: ids,
                existing: self.units,
                refreshMode: .update,
                success: { newUnits in
                    self.loadProgressesForUnits(units: newUnits, completion: {
                        self.loadLessonsForUnits(units: newUnits, completion: {
                            idsDownloaded(newUnits)
                        }, error: {
                            print("Error while downloading units")
                            errorWhileDownloading()
                        })
                    }, error: {
                        print("Error while downloading units")
                        errorWhileDownloading()
                    })
                },
                error: { _ in
                    print("Error while downloading units")
                    errorWhileDownloading()
                }
            )
        }
    }

    @available(*, deprecated, message: "Legacy")
    func loadProgressesForUnits(
        units: [Unit],
        completion: @escaping (() -> Void),
        error errorHandler: (() -> Void)? = nil
    ) {
        var progressIds: [String] = []
        var progresses: [Progress] = []
        for unit in units {
            if let progressId = unit.progressId {
                progressIds += [progressId]
            }
            if let progress = unit.progress {
                progresses += [progress]
            }
        }

        _ = ApiDataDownloader.progresses.retrieve(
            ids: progressIds,
            existing: progresses,
            refreshMode: .update,
            success: { newProgresses -> Void in
                progresses = Sorter.sort(newProgresses, byIds: progressIds)
                for i in 0..<min(units.count, progresses.count) {
                    units[i].progress = progresses[i]
                }

                CoreDataHelper.shared.save()

                completion()
            },
            error: { (_) -> Void in
                errorHandler?()
                print("Error while dowloading progresses")
            }
        )
    }

    @available(*, deprecated, message: "Legacy")
    func loadLessonsForUnits(
        units: [Unit],
        completion: @escaping (() -> Void),
        error errorHandler: (() -> Void)? = nil
    ) {
        var lessonIds: [Int] = []
        var lessons: [Lesson] = []
        for unit in units {
            lessonIds += [unit.lessonId]
            if let lesson = unit.lesson {
                lessons += [lesson]
            }
        }

        _ = ApiDataDownloader.lessons.retrieve(
            ids: lessonIds,
            existing: lessons,
            refreshMode: .update,
            success: { newLessons in
                lessons = Sorter.sort(newLessons, byIds: lessonIds)

                for i in 0..<units.count {
                    units[i].lesson = lessons[i]
                }

                CoreDataHelper.shared.save()

                completion()
            },
            error: { _ in
                print("Error while downloading units")
                errorHandler?()
            }
        )
    }

    enum JSONKey: String {
        case id
        case title
        case position
        case isActive = "is_active"
        case progress
        case beginDate = "begin_date"
        case endDate = "end_date"
        case beginDateSource = "begin_date_source"
        case endDateSource = "end_date_source"
        case softDeadline = "soft_deadline"
        case hardDeadline = "hard_deadline"
        case actions
        case testSection = "test_section"
        case isExam = "is_exam"
        case units
        case course
        case discountingPolicy = "discounting_policy"
        case isRequirementSatisfied = "is_requirement_satisfied"
        case requiredSection = "required_section"
        case requiredPercent = "required_percent"
        case examDurationMinutes = "exam_duration_minutes"
        case examSession = "exam_session"
        case proctorSession = "proctor_session"
        case isProctoringCanBeScheduled = "is_proctoring_can_be_scheduled"
    }
}
