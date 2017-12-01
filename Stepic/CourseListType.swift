//
//  CourseListType.swift
//  Stepic
//
//  Created by Ostrenkiy on 29.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

enum CourseListType {
    case enrolled
    case popular
    case collection(ids: [Int])
    case search(query: String)
    case tag(id: Int)

    private func requestAllEnrolled(coursesAPI: CoursesAPI, progressesAPI: ProgressesAPI) -> Promise<([Course], Meta)>? {
        return Promise {
            fulfill, reject in
            loadPageWithProgresses(loadedCourses: [], page: 1, coursesAPI: coursesAPI, progressesAPI: progressesAPI, success: {
                courses, meta in
                let res = courses.sorted(by: {
                    guard let lastViewed1 = $0.progress?.lastViewed, let lastViewed2 = $1.progress?.lastViewed else {
                        return false
                    }
                    return lastViewed1 > lastViewed2
                })
                fulfill((res, meta))
            }, error: {
                error in
                reject(error)
            })
        }
    }

    private func loadPageWithProgresses(loadedCourses: [Course], page: Int, coursesAPI: CoursesAPI, progressesAPI: ProgressesAPI, success: @escaping ([Course], Meta) -> Void, error errorHandler: @escaping (Error) -> Void) {

        coursesAPI.retrieve(enrolled: true, order: "-activity", page: page).then {
            courses, meta -> Void in

            guard !courses.isEmpty else {
                success(loadedCourses, meta)
                return
            }

            var progressIds: [String] = []
            var progresses: [Progress] = []
            for course in courses {
                if let progressId = course.progressId {
                    progressIds += [progressId]
                }
                if let progress = course.progress {
                    progresses += [progress]
                }
            }

            //Not calling this in next "then" because courses values are needed to proceed further
            progressesAPI.getObjectsByIds(ids: progressIds, updating: progresses).then {
                newProgresses -> Void in
                let progresses = Sorter.sort(newProgresses, byIds: progressIds)

                if progresses.count == 0 {
                    CoreDataHelper.instance.save()
                    return
                }

                var progressCnt = 0
                for i in 0 ..< courses.count {
                    if courses[i].progressId == progresses[progressCnt].id {
                        courses[i].progress = progresses[progressCnt]
                        progressCnt += 1
                    }
                    if progressCnt == progresses.count {
                        break
                    }
                }
                CoreDataHelper.instance.save()
                if meta.hasNext {
                    self.loadPageWithProgresses(loadedCourses: loadedCourses + courses, page: page + 1, coursesAPI: coursesAPI, progressesAPI: progressesAPI, success: success, error: errorHandler)
                } else {
                    success(loadedCourses + courses, meta)
                }
                }.catch {
                    error in
                    errorHandler(error)
            }
            }.catch {
                error in
                errorHandler(error)
        }
    }

    func request(page: Int, language: ContentLanguage, withAPI coursesAPI: CoursesAPI, progressesAPI: ProgressesAPI, searchResultsAPI: SearchResultsAPI) -> Promise<([Course], Meta)>? {

        let requestedLanguage: ContentLanguage? = language == .russian ? nil : language

        switch self {
        case .popular:
            return coursesAPI.retrieve(excludeEnded: true, isPublic: true, order: "-activity", language: requestedLanguage, page: page)
        case .enrolled:
            return requestAllEnrolled(coursesAPI: coursesAPI, progressesAPI: progressesAPI)
        case let .search(query: query):
            var resultMeta: Meta = Meta(hasNext: false, hasPrev: false, page: 1)
            var searchCoursesIDs: [Int] = []
            return Promise<([Course], Meta)> {
                fulfill, reject in
                searchResultsAPI.searchCourse(query: query, language: requestedLanguage, page: page).then {
                    (searchResults, meta) -> Promise<([Course])> in
                    resultMeta = meta
                    searchCoursesIDs = searchResults.flatMap { $0.courseId }
                    return coursesAPI.retrieve(ids: searchCoursesIDs, existing: Course.getCourses(searchCoursesIDs))
                    }.then {
                        (courses) -> Void in
                        let resultCourses = Sorter.sort(courses, byIds: searchCoursesIDs)
                        fulfill((resultCourses, resultMeta))
                    }.catch {
                        error in
                        reject(error)
                }
            }
        case let .tag(id: id):
            return coursesAPI.retrieve(tag: id, order: "-activity", language: requestedLanguage, page: page)
        default:
            return nil
        }
    }

    func request(coursesWithIds ids: [Int], withAPI coursesAPI: CoursesAPI) -> Promise<[Course]>? {
        switch self {
        case let .collection(ids: ids):
            return coursesAPI.retrieve(ids: ids, existing: Course.getCourses(ids))
        default:
            return nil
        }
    }

    private var cacheId: String? {
        switch self {
        case .popular:
            return "PopularCoursesInfo_\(ContentLanguage.sharedContentLanguage.languageString)"
        case .enrolled:
            return "MyCoursesInfo"
        default:
            return nil
        }
    }

    var cachedListCourseIds: [Int] {
        get {
            guard let cacheId = self.cacheId, let ids = UserDefaults.standard.object(forKey: cacheId) as? [Int] else {
                switch self {
                case let .collection(ids: ids):
                    return ids
                default:
                    return []
                }
            }
            return ids
        }

        set(newIds) {
            guard let cacheId = self.cacheId else {
                return
            }
            UserDefaults.standard.set(newIds, forKey: cacheId)
            UserDefaults.standard.synchronize()
        }
    }
}
