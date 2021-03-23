//
//  CourseReview.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12/02/2019.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation
import PromiseKit
import SwiftyJSON

final class CourseReview: NSManagedObject, JSONSerializable, IDFetchable {
    typealias IdType = Int

    var json: JSON {
        [
            "course": self.courseID,
            "user": self.userID,
            "score": self.score,
            "text": self.text
        ]
    }

    required convenience init(json: JSON) {
        self.init()
        initialize(json)
    }

    func initialize(_ json: JSON) {
        id = json["id"].intValue
        text = json["text"].stringValue
        userID = json["user"].intValue
        courseID = json["course"].intValue
        score = json["score"].intValue
        creationDate = Parser.dateFromTimedateJSON(json["create_date"]) ?? Date()
    }

    func update(json: JSON) {
        initialize(json)
    }

    static func fetch(courseID: Course.IdType) -> Guarantee<[CourseReview]> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CourseReview")
        let descriptor = NSSortDescriptor(key: "managedId", ascending: false)

        let predicate = NSPredicate(format: "managedCourseId == %@", courseID.fetchValue)

        request.predicate = predicate
        request.sortDescriptors = [descriptor]

        return Guarantee { seal in
            DispatchQueue.doWorkOnMain {
                let context = CoreDataHelper.shared.context
                context.performAndWait {
                    do {
                        let courseReviews = try context.fetch(request) as? [CourseReview]
                        seal(courseReviews ?? [])
                    } catch {
                        seal([])
                    }
                }
            }
        }
    }

    static func fetch(courseID: Course.IdType, userID: User.IdType) -> Guarantee<[CourseReview]> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CourseReview")
        let descriptor = NSSortDescriptor(key: "managedId", ascending: false)

        let courseIDPredicate = NSPredicate(format: "managedCourseId == %@", courseID.fetchValue)
        let userIDPredicate = NSPredicate(format: "managedUserId == %@", userID.fetchValue)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [courseIDPredicate, userIDPredicate])

        request.predicate = predicate
        request.sortDescriptors = [descriptor]

        return Guarantee { seal in
            DispatchQueue.doWorkOnMain {
                let context = CoreDataHelper.shared.context
                context.performAndWait {
                    do {
                        let courseReviews = try context.fetch(request) as? [CourseReview]
                        seal(courseReviews ?? [])
                    } catch {
                        seal([])
                    }
                }
            }
        }
    }

    static func delete(_ id: CourseReview.IdType) -> Guarantee<Void> {
        CourseReview.fetchAsync(ids: [id]).done { courseReviews in
            courseReviews.forEach {
                CoreDataHelper.shared.deleteFromStore($0, save: false)
            }
            CoreDataHelper.shared.save()
        }
    }
}
