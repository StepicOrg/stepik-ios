//
//  CourseInfoTabReviewsInteractor.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/02/2019.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol CourseInfoTabReviewsInteractorProtocol: class {
    func fetchCourseReviews()
    func fetchNextReviews(request: CourseInfoTabReviews.LoadNextReviews.Request)
}

final class CourseInfoTabReviewsInteractor: CourseInfoTabReviewsInteractorProtocol {
    let presenter: CourseInfoTabReviewsPresenterProtocol
    let provider: CourseInfoTabReviewsProviderProtocol

    private var currentCourse: Course?
    private var isOnline = false
    private var shouldOpenedAnalyticsEventSend = false

    // Semaphore to prevent concurrent fetching
    private let fetchSemaphore = DispatchSemaphore(value: 1)
    private lazy var fetchBackgroundQueue = DispatchQueue(label: "com.AlexKarpov.Stepic.CourseInfoTabReviewsInteractor.ReviewsFetch")

    init(
        presenter: CourseInfoTabReviewsPresenterProtocol,
        provider: CourseInfoTabReviewsProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func fetchCourseReviews() {
        guard let course = self.currentCourse else {
            return
        }

        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()

            let isOnline = strongSelf.isOnline
            print("course info tab reviews interactor: start fetching reviews, isOnline = \(isOnline)")

            strongSelf.fetchReviewsInAppropriateMode(
                course: course,
                isOnline: isOnline
            ).done { response in
                DispatchQueue.main.async {
                    print("course info tab reviews interactor: finish fetching reviews, isOnline = \(isOnline)")
                    strongSelf.presenter.presentCourseReviews(response: response)
                }
            }.catch { _ in
                // TODO: handle
            }.finally {
                strongSelf.fetchSemaphore.signal()
            }
        }
    }

    func fetchNextReviews(request: CourseInfoTabReviews.LoadNextReviews.Request) {

    }

    private func fetchReviewsInAppropriateMode(
        course: Course,
        isOnline: Bool
    ) -> Promise<CourseInfoTabReviews.ShowReviews.Response> {
        guard let course = self.currentCourse else {
            return Promise(error: Error.undefinedCourse)
        }

        return Promise { seal in
            firstly {
                isOnline
                    ? self.provider.fetchCached(course: course)
                    : self.provider.fetchRemote(course: course, page: 1)
            }.done { reviews, meta in
                let sortedReviews = reviews.sorted { $0.creationDate > $1.creationDate }
                let response = CourseInfoTabReviews.ShowReviews.Response(
                    reviews: sortedReviews,
                    hasNextPage: meta.hasNext
                )
                seal.fulfill(response)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case undefinedCourse
        case fetchFailed
    }
}

extension CourseInfoTabReviewsInteractor: CourseInfoTabReviewsInputProtocol {
    func handleControllerAppearance() {
        if let course = self.currentCourse {
            AmplitudeAnalyticsEvents.CourseReviews.opened(
                courseID: course.id,
                courseTitle: course.title
            ).send()
            self.shouldOpenedAnalyticsEventSend = false
        } else {
            self.shouldOpenedAnalyticsEventSend = true
        }
    }

    func update(with course: Course, isOnline: Bool) {
        self.currentCourse = course
        self.isOnline = isOnline

        self.fetchCourseReviews()

        if self.shouldOpenedAnalyticsEventSend {
            AmplitudeAnalyticsEvents.CourseReviews.opened(
                courseID: course.id,
                courseTitle: course.title
            ).send()
            self.shouldOpenedAnalyticsEventSend = false
        }
    }
}
