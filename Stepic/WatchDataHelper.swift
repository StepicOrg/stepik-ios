//
//  WatchDataHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 19.12.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class WatchDataHelper {

    private init() {}

    @available(iOS 9.0, *)
    static func parseAndAddPlainCourses(_ courses: [Course]) {
        var limit = courses.count
        let maxL = limit

        var ids: [Int] = []
        var coursesToProcess: [Course] = []
        var plainCourses: [CoursePlainEntity] = []

        for course in courses {
            if limit == 0 {
                break
            }

            ids += [course.id]
            WatchSessionSender.sendMetainfo(metainfoContainer: course.metaInfoContainer)
            if let deadlines = course.nearestDeadlines {
                let plainCourse = CoursePlainEntity(id: course.id, name: course.title, metainfo: course.metaInfo, imageURL: course.coverURLString, firstDeadlineDate: deadlines.nearest, secondDeadlineDate: deadlines.second)
                plainCourses += [plainCourse]
            } else {
                coursesToProcess += [course]
            }
            limit -= 1
        }

        let tryCompletion = {
            if plainCourses.count == maxL - limit {
                WatchSessionSender.sendPlainCourses(Sorter.sort(plainCourses, byIds: ids))
            }
        }

        guard coursesToProcess.count > 0 else {
            tryCompletion()
            return
        }

        for course in coursesToProcess {
            course.loadAllSections(success: {
                let plainCourse = CoursePlainEntity(id: course.id, name: course.title, metainfo: course.metaInfo, imageURL: course.coverURLString, firstDeadlineDate: course.nearestDeadlines?.nearest, secondDeadlineDate: course.nearestDeadlines?.second)
                plainCourses += [plainCourse]
                tryCompletion()
            }, error: {
                print("error while downloading deadlines for course \(course.id)")
                let plainCourse = CoursePlainEntity(id: course.id, name: course.title, metainfo: course.metaInfo, imageURL: course.coverURLString, firstDeadlineDate: course.nearestDeadlines?.nearest, secondDeadlineDate: course.nearestDeadlines?.second)
                plainCourses += [plainCourse]
                tryCompletion()
            })
        }

    }
}
