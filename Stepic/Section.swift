//
//  Section.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc
final class Section: NSManagedObject, IDFetchable {

    // Insert code here to add functionality to your managed object subclass
    typealias IdType = Int

    convenience required init(json: JSON) {
        self.init()
        initialize(json)
    }

    func initialize(_ json: JSON) {
        id = json["id"].intValue
        title = json["title"].stringValue
        position = json["position"].intValue
        isActive = json["is_active"].boolValue
        progressId = json["progress"].string
        //        print("initialized section \(id) with progress id -> \(progressId)")
        beginDate = Parser.sharedParser.dateFromTimedateJSON(json["begin_date"])
        endDate = Parser.sharedParser.dateFromTimedateJSON(json["end_date"])
        softDeadline = Parser.sharedParser.dateFromTimedateJSON(json["soft_deadline"])
        hardDeadline = Parser.sharedParser.dateFromTimedateJSON(json["hard_deadline"])

        testSectionAction = json["actions"]["test_section"].string
        isExam = json["is_exam"].boolValue
        unitsArray = json["units"].arrayObject as! [Int]
        courseId = json["course"].intValue
    }

    func update(json: JSON) {
        initialize(json)
    }

    static func fetch(_ ids: [Int]) -> [Section] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Section")

        let idPredicates = ids.map {
            NSPredicate(format: "managedId == %@", $0 as NSNumber)
        }
        request.predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: idPredicates)
        do {
            guard let results = try CoreDataHelper.instance.context.fetch(request) as? [Section] else {
                return []
            }
            return results
        } catch {
            return []
        }
    }

    class func getSections(_ id: Int) throws -> [Section] {
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

    func loadUnits(success: @escaping (() -> Void), error errorHandler : @escaping (() -> Void)) {

        if self.unitsArray.count == 0 {
            success()
            return
        }

        let requestUnitsCount = 50
        var dimCount = 0
        var idsArray = Array<Array<Int>>()
        for (index, unitId) in self.unitsArray.enumerated() {
            if index % requestUnitsCount == 0 {
                idsArray.append(Array<Int>())
                dimCount += 1
            }
            idsArray[dimCount - 1].append(unitId)
        }

        //            let sectionsToDownload = idsArray.count
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

    //    func loadIfNotLoaded(success success : (Void -> Void)) {
    //        if !loaded {
    //            ApiDataDownloader.sharedDownloader.getSectionById(id, existingSection: self, refreshToken: false, success: {
    //                    sec in
    //                    success()
    //                }, failure: {
    //                    error in
    //                    print("failed to load section with id -> \(self.id)")
    //            })
    //        } else {
    //            success()
    //        }
    //    }
}
