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
}

final class CourseInfoTabReviewsPresenter: CourseInfoTabReviewsPresenterProtocol {
    weak var viewController: CourseInfoTabReviewsViewControllerProtocol?

    func presentCourseReviews(response: CourseInfoTabReviews.ShowReviews.Response) {
        let viewModel: CourseInfoTabReviews.ShowReviews.ViewModel = .init(
            state: CourseInfoTabReviews.ViewControllerState.result(
                data: .init(
                    reviews: response.reviews.map { self.makeViewModel(courseReview: $0) },
                    hasNextPage: response.hasNextPage
                )
            )
        )
        self.viewController?.displayReviews(viewModel: viewModel)
    }

    private func makeViewModel(courseReview: CourseReview) -> CourseInfoTabReviewsViewModel {
        return CourseInfoTabReviewsViewModel(
            userName: "Anonymous",
            dateRepresentation: FormatterHelper.dateStringWithFullMonthAndYear(courseReview.creationDate),
            text: courseReview.text,
            avatarImageURL: URL(string: "https://stepik.org/users/38651314/251c06002a701e6d6991dac7ff9dc90b83d1e7b6/avatar.svg"),
            score: courseReview.score
        )
    }
}
