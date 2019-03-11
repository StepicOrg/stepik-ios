//
//  CourseListsCollectionInteractor.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 03.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol CourseListsCollectionInteractorProtocol: class {
    func doCourseListsFetch(request: CourseListsCollection.CourseListsLoad.Request)
    func doFullscreenCourseListPresentation(
        request: CourseListsCollection.FullscreenCourseListModulePresentation.Request
    )
}

final class CourseListsCollectionInteractor: CourseListsCollectionInteractorProtocol {
    weak var moduleOutput: (CourseListCollectionOutputProtocol & CourseListOutputProtocol)?

    private let presenter: CourseListsCollectionPresenterProtocol
    private let provider: CourseListsCollectionProviderProtocol

    init(
        presenter: CourseListsCollectionPresenterProtocol,
        provider: CourseListsCollectionProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doCourseListsFetch(request: CourseListsCollection.CourseListsLoad.Request) {
        self.provider.fetchCachedCourseLists().then {
            cachedCourseLists -> Promise<[CourseListModel]> in
            // Pass cached data to presenter and start fetching from remote
            let response = Result<[CourseListModel]>.success(cachedCourseLists)
            self.presenter.presentCourses(
                response: CourseListsCollection.CourseListsLoad.Response(result: response)
            )

            return self.provider.fetchRemoteCourseLists()
        }.done { remoteCourseLists in
            let response = Result<[CourseListModel]>.success(remoteCourseLists)
            self.presenter.presentCourses(
                response: CourseListsCollection.CourseListsLoad.Response(result: response)
            )

            self.presenter.presentCourses(
                response: CourseListsCollection.CourseListsLoad.Response(result: response)
            )
        }.catch { _ in

        }
    }

    func doFullscreenCourseListPresentation(
        request: CourseListsCollection.FullscreenCourseListModulePresentation.Request
    ) {
        guard let collectionCourseListType = request.courseListType
            as? CollectionCourseListType else {
            return
        }

        self.moduleOutput?.presentCourseList(
            presentationDescription: request.presentationDescription,
            type: collectionCourseListType
        )
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}

extension CourseListsCollectionInteractor: CourseListOutputProtocol {
    func presentCourseInfo(course: Course) {
        self.moduleOutput?.presentCourseInfo(course: course)
    }

    func presentCourseSyllabus(course: Course) {
        self.moduleOutput?.presentCourseSyllabus(course: course)
    }

    func presentLastStep(course: Course, isAdaptive: Bool) {
        self.moduleOutput?.presentLastStep(course: course, isAdaptive: isAdaptive)
    }

    func presentAuthorization() {
        self.moduleOutput?.presentAuthorization()
    }

    func presentEmptyState(sourceModule: CourseListInputProtocol) {

    }

    func presentError(sourceModule: CourseListInputProtocol) {
    }
}
