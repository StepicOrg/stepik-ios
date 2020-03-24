//
//  Lesson.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation
import SwiftyJSON

final class Lesson: NSManagedObject, IDFetchable {
    typealias IdType = Int

    var isCached: Bool {
        if self.steps.isEmpty {
            return false
        }

        for video in self.getVideos() {
            if video.state != .cached {
                return false
            }
        }

        return true
    }

    required convenience init(json: JSON) {
        self.init()
        self.initialize(json)
    }

    func initialize(_ json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.title = json[JSONKey.title.rawValue].stringValue
        self.isFeatured = json[JSONKey.isFeatured.rawValue].boolValue
        self.isPublic = json[JSONKey.isPublic.rawValue].boolValue
        self.slug = json[JSONKey.slug.rawValue].stringValue
        self.coverURL = json[JSONKey.coverURL.rawValue].string
        self.timeToComplete = json[JSONKey.timeToComplete.rawValue].doubleValue
        self.stepsArray = json[JSONKey.steps.rawValue].arrayObject as! [Int]
        self.passedBy = json[JSONKey.passedBy.rawValue].intValue
        self.voteDelta = json[JSONKey.voteDelta.rawValue].intValue

        if let actionsDictionary = json[JSONKey.actions.rawValue].dictionary {
            self.canEdit = actionsDictionary[JSONKey.editLesson.rawValue]?.stringValue == JSONKey.actionStatusGranted
        }
    }

    func update(json: JSON) {
        self.initialize(json)
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
            CoreDataHelper.shared.save()
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
            if let progressId = step.progressID {
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

            CoreDataHelper.shared.save()

            completion()
            }, error: {
                (_) -> Void in
                print("Error while downloading progresses")
        })
    }

    func getVideoURLs() -> [String] {
        var videoURLs = [String]()

        for step in self.steps where step.block.type == .video {
            if let video = step.block.video {
                videoURLs += [video.urls[0].url]
            }
        }

        return videoURLs
    }

    func getVideos() -> [Video] {
        var videos = [Video]()

        for step in self.steps where step.block.type == .video {
            if let video = step.block.video {
                videos += [video]
            }
        }

        return videos
    }

    static func getLesson(_ id: IdType) -> Lesson? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Lesson")
        request.predicate = NSPredicate(format: "managedId== %@", id as NSNumber)

        do {
            let results = try CoreDataHelper.shared.context.fetch(request)
            return (results as? [Lesson])?.first
        } catch {
            return nil
        }
    }

    static func fetch(_ ids: [IdType]) -> [Lesson] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Lesson")

        let idPredicates = ids.map { NSPredicate(format: "managedId == %@", $0 as NSNumber) }
        request.predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: idPredicates)

        do {
            guard let results = try CoreDataHelper.shared.context.fetch(request) as? [Lesson] else {
                return []
            }
            return results
        } catch {
            return []
        }
    }

    // MARK: - Types

    enum JSONKey: String {
        static let actionStatusGranted = "#"

        case id
        case title
        case isFeatured = "is_featured"
        case isPublic = "is_public"
        case slug
        case coverURL = "cover_url"
        case timeToComplete = "time_to_complete"
        case steps
        case passedBy = "passed_by"
        case voteDelta = "vote_delta"
        case actions
        case editLesson = "edit_lesson"
    }
}
