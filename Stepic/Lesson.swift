//
//  Lesson.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

final class Lesson: NSManagedObject, IDFetchable {

    // Insert code here to add functionality to your managed object subclass
    typealias IdType = Int

    convenience required init(json: JSON) {
        self.init()
        initialize(json)
    }

    func initialize(_ json: JSON) {
        id = json["id"].intValue
        title = json["title"].stringValue
        isFeatured = json["is_featured"].boolValue
        isPublic = json["is_public"].boolValue
        slug = json["slug"].stringValue
        coverURL = json["cover_url"].string
        timeToComplete = json["time_to_complete"].doubleValue
        stepsArray = json["steps"].arrayObject as! [Int]
        passedBy = json["passed_by"].intValue
        voteDelta = json["vote_delta"].intValue
    }

    static func getLesson(_ id: Int) -> Lesson? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Lesson")

        let predicate = NSPredicate(format: "managedId== %@", id as NSNumber)

        request.predicate = predicate

        do {
            let results = try CoreDataHelper.instance.context.fetch(request)
            return (results as? [Lesson])?.first
        } catch {
            return nil
        }

//        return Lesson.MR_findFirstWithPredicate(NSPredicate(format: "managedId == %@", id as NSNumber))
    }

    func update(json: JSON) {
        initialize(json)
    }

    func loadSteps(completion: @escaping (() -> Void), error errorHandler: ((String) -> Void)? = nil, onlyLesson: Bool = false) {
        _ = ApiDataDownloader.steps.retrieve(ids: self.stepsArray, existing: self.steps, refreshMode: .update, success: {
            newSteps in
            self.steps = Sorter.sort(newSteps, byIds: self.stepsArray)
            self.loadProgressesForSteps({
                if !onlyLesson {
                    if let u = self.unit {
                        _ = ApiDataDownloader.assignments.retrieve(ids: u.assignmentsArray, existing: u.assignments, refreshMode: .update, success: {
                            newAssignments in
                            u.assignments = Sorter.sort(newAssignments, steps: self.steps)
                            completion()
                            }, error: {
                                _ in
                                print("Error while downloading assignments")
                                errorHandler?("Error while downloading assignments")
                        })
                    } else {
                        completion()
                    }
                } else {
                    completion()
                }
            })
            CoreDataHelper.instance.save()
            }, error: {
                _ in
                print("Error while downloading steps")
                errorHandler?("Error while downloading steps")
        })

    }

    func loadProgressesForSteps(_ completion: @escaping (() -> Void)) {
        var progressIds: [String] = []
        var progresses: [Progress] = []
        for step in steps {
            if let progressId = step.progressId {
                progressIds += [progressId]
            }
            if let progress = step.progress {
                progresses += [progress]
            }
        }

        _ = ApiDataDownloader.progresses.retrieve(ids: progressIds, existing: progresses, refreshMode: .update, success: {
            newProgresses -> Void in
            progresses = Sorter.sort(newProgresses, byIds: progressIds)
            for i in 0 ..< min(self.steps.count, progresses.count) {
                self.steps[i].progress = progresses[i]
            }

            CoreDataHelper.instance.save()

            completion()
            }, error: {
                (_) -> Void in
                print("Error while dowloading progresses")
        })
    }

    func getVideoURLs() -> [String] {
        var res: [String] = []
        for step in steps {
            if step.block.name == "video" {
                if let vid = step.block.video {
                    res += [vid.urls[0].url]
                }
            }
        }
        return res
    }

    var stepVideos: [Video] {
        var res: [Video] = []
        for step in steps {
            if step.block.name == "video" {
                if let video = step.block.video {
                    res += [video]
                }
            }
        }

        return res
    }

    var isCached: Bool {
        if steps.count == 0 {
            return false
        }

        for vid in stepVideos {
            if vid.state != VideoState.cached {
                return false
            }
        }
        return true
    }

    static func fetch(_ ids: [Int]) -> [Lesson] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Lesson")

        let idPredicates = ids.map {
            NSPredicate(format: "managedId == %@", $0 as NSNumber)
        }
        request.predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: idPredicates)
        do {
            guard let results = try CoreDataHelper.instance.context.fetch(request) as? [Lesson] else {
                return []
            }
            return results
        } catch {
            return []
        }
    }
}
