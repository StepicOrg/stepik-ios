//
//  Section.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation
import SwiftyJSON

@objc
final class Section: NSManagedObject, IDFetchable {
    typealias IdType = Int

    required convenience init(json: JSON) {
        self.init()
        self.initialize(json)
    }

    func initialize(_ json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.title = json[JSONKey.title.rawValue].stringValue
        self.position = json[JSONKey.position.rawValue].intValue
        self.isActive = json[JSONKey.isActive.rawValue].boolValue
        self.progressId = json[JSONKey.progress.rawValue].string
        self.isExam = json[JSONKey.isExam.rawValue].boolValue
        self.unitsArray = json[JSONKey.units.rawValue].arrayObject as! [Int]
        self.courseId = json[JSONKey.course.rawValue].intValue
        self.testSectionAction = json[JSONKey.actions.rawValue][JSONKey.testSection.rawValue].string
        self.discountingPolicy = json[JSONKey.discountingPolicy.rawValue].string
        // Required section
        self.isRequirementSatisfied = json[JSONKey.isRequirementSatisfied.rawValue].bool ?? true
        self.requiredSectionID = json[JSONKey.requiredSection.rawValue].int
        self.requiredPercent = json[JSONKey.requiredPercent.rawValue].intValue
        // Dates
        self.beginDate = Parser.shared.dateFromTimedateJSON(json[JSONKey.beginDate.rawValue])
        self.endDate = Parser.shared.dateFromTimedateJSON(json[JSONKey.endDate.rawValue])
        self.softDeadline = Parser.shared.dateFromTimedateJSON(json[JSONKey.softDeadline.rawValue])
        self.hardDeadline = Parser.shared.dateFromTimedateJSON(json[JSONKey.hardDeadline.rawValue])
    }

    func update(json: JSON) {
        self.initialize(json)
    }

    static func fetch(_ ids: [IdType]) -> [Section] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Section")
        let idPredicates = ids.map { NSPredicate(format: "managedId == %@", $0 as NSNumber) }
        request.predicate = NSCompoundPredicate(type: .or, subpredicates: idPredicates)

        var sections = [Section]()
        CoreDataHelper.instance.context.performAndWait {
            do {
                sections = try CoreDataHelper.instance.context.fetch(request) as? [Section] ?? []
            } catch {
                sections = []
            }
        }

        return sections
    }

    static func getSections(_ id: Int) throws -> [Section] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Section")

        let descriptor = NSSortDescriptor(key: "managedId", ascending: false)
        var predicate = NSPredicate(value: true)

        let p = NSPredicate(format: "managedId == %@", id as NSNumber)
        predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, p])

        request.predicate = predicate
        request.sortDescriptors = [descriptor]

        do {
            let results = try CoreDataHelper.instance.context.fetch(request)
            return results as! [Section]
        } catch {
            throw DatabaseError.fetchFailed
        }
    }

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
                CoreDataHelper.instance.save()
                success()
            }
        }

        var wasError = false
        let errorWhileDownloading : () -> Void = {
            if !wasError {
                wasError = true
                errorHandler()
            }
        }

        for ids in idsArray {
            _ = ApiDataDownloader.units.retrieve(ids: ids, existing: self.units, refreshMode: .update, success: {
                newUnits in
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
                }, error: {
                    _ in
                    print("Error while downloading units")
                    errorWhileDownloading()
            })
        }
    }

    func loadProgressesForUnits(units: [Unit], completion: @escaping (() -> Void), error errorHandler: (() -> Void)? = nil) {
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

        _ = ApiDataDownloader.progresses.retrieve(ids: progressIds, existing: progresses, refreshMode: .update, success: {
            newProgresses -> Void in
            progresses = Sorter.sort(newProgresses, byIds: progressIds)
            for i in 0 ..< min(units.count, progresses.count) {
                units[i].progress = progresses[i]
            }

            CoreDataHelper.instance.save()

            completion()
            }, error: {
                (_) -> Void in
                errorHandler?()
                print("Error while dowloading progresses")
        })
    }

    func loadLessonsForUnits(units: [Unit], completion: @escaping (() -> Void), error errorHandler: (() -> Void)? = nil) {
        var lessonIds: [Int] = []
        var lessons: [Lesson] = []
        for unit in units {
            lessonIds += [unit.lessonId]
            if let lesson = unit.lesson {
                lessons += [lesson]
            }
        }

        _ = ApiDataDownloader.lessons.retrieve(ids: lessonIds, existing: lessons, refreshMode: .update, success: {
            newLessons in
            lessons = Sorter.sort(newLessons, byIds: lessonIds)

            for i in 0 ..< units.count {
                units[i].lesson = lessons[i]
            }

            CoreDataHelper.instance.save()

            completion()
            }, error: {
                _ in
                print("Error while downloading units")
                errorHandler?()
        })
    }

    func isCompleted(_ lessons: [Lesson]) -> Bool {
        for lesson in lessons {
            if !lesson.isCached {
                return false
            }
        }
        return true
    }

    var isCached: Bool {
        get {
            if units.count == 0 {
                return false
            }
            for unit in units {
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

    var isReachable: Bool {
        return (self.isActive || self.testSectionAction != nil) && (self.progressId != nil || self.isExam)
    }

    enum JSONKey: String {
        case id
        case title
        case position
        case isActive = "is_active"
        case progress
        case beginDate = "begin_date"
        case endDate = "end_date"
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
    }
}

// MARK: - Section: NextLessonServiceSectionSourceProtocol -

extension Section: NextLessonServiceSectionSourceProtocol {
    var unitsList: [NextLessonServiceUnitSourceProtocol] {
        return self.units
    }

    var uniqueIdentifier: UniqueIdentifierType {
        return "\(id)"
    }
}
