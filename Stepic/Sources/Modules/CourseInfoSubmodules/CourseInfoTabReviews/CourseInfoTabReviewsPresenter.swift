//
//  CourseInfoTabReviewsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/02/2019.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import Foundation

protocol CourseInfoTabReviewsPresenterProtocol: class {
    func presentCourseReviews(response: CourseInfoTabReviews.ReviewsLoad.Response)
    func presentNextCourseReviews(response: CourseInfoTabReviews.NextReviewsLoad.Response)
}

final class CourseInfoTabReviewsPresenter: CourseInfoTabReviewsPresenterProtocol {
    weak var viewController: CourseInfoTabReviewsViewControllerProtocol?

    func presentCourseReviews(response: CourseInfoTabReviews.ReviewsLoad.Response) {
        let viewModel: CourseInfoTabReviews.ReviewsLoad.ViewModel = .init(
            state: CourseInfoTabReviews.ViewControllerState.result(
                data: .init(
                    reviews: response.reviews.compactMap { self.makeViewModel(courseReview: $0) },
                    hasNextPage: response.hasNextPage
                )
            )
        )
        self.viewController?.displayCourseReviews(viewModel: viewModel)
    }

    func presentNextCourseReviews(response: CourseInfoTabReviews.NextReviewsLoad.Response) {
        let viewModel: CourseInfoTabReviews.NextReviewsLoad.ViewModel = .init(
            state: CourseInfoTabReviews.PaginationState.result(
                data: .init(
                    reviews: response.reviews.compactMap { self.makeViewModel(courseReview: $0) },
                    hasNextPage: response.hasNextPage
                )
            )
        )
        self.viewController?.displayNextCourseReviews(viewModel: viewModel)
    }

    private func makeViewModel(courseReview: CourseReview) -> CourseInfoTabReviewsViewModel? {
        guard let reviewAuthor = courseReview.user else {
            return nil
        }

        return CourseInfoTabReviewsViewModel(
            userName: reviewAuthor.fullName,
            dateRepresentation: FormatterHelper.dateStringWithFullMonthAndYear(courseReview.creationDate),
            text: courseReview.text.trimmingCharacters(in: .whitespacesAndNewlines),
            avatarImageURL: URL(string: reviewAuthor.avatarURL),
            score: courseReview.score
        )
    }
}
