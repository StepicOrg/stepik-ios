//
//  CourseInfoTabReviewsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/02/2019.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import Foundation

protocol CourseInfoTabReviewsPresenterProtocol: class {
    func presentCourseReviews(response: CourseInfoTabReviews.ShowReviews.Response)
    func presentNextCourseReviews(response: CourseInfoTabReviews.LoadNextReviews.Response)
}

final class CourseInfoTabReviewsPresenter: CourseInfoTabReviewsPresenterProtocol {
    weak var viewController: CourseInfoTabReviewsViewControllerProtocol?

    func presentCourseReviews(response: CourseInfoTabReviews.ShowReviews.Response) {
        let viewModel: CourseInfoTabReviews.ShowReviews.ViewModel = .init(
            state: CourseInfoTabReviews.ViewControllerState.result(
                data: .init(
                    reviews: response.reviews.compactMap { self.makeViewModel(courseReview: $0) },
                    hasNextPage: response.hasNextPage
                )
            )
        )
        self.viewController?.displayReviews(viewModel: viewModel)
    }

    func presentNextCourseReviews(response: CourseInfoTabReviews.LoadNextReviews.Response) {
        let viewModel: CourseInfoTabReviews.LoadNextReviews.ViewModel = .init(
            state: CourseInfoTabReviews.PaginationState.result(
                data: .init(
                    reviews: response.reviews.compactMap { self.makeViewModel(courseReview: $0) },
                    hasNextPage: response.hasNextPage
                )
            )
        )
        self.viewController?.displayNextReviews(viewModel: viewModel)
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
