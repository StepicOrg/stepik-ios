//
//  CourseInfoTabReviewsDataFlow.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/02/2019.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import Foundation

enum CourseInfoTabReviews {
    // MARK: Common structs

    struct ReviewsResult {
        let reviews: [CourseInfoTabReviewsViewModel]
        let hasNextPage: Bool
    }

    // MARK: Use cases

    /// Show reviews
    enum ShowReviews {
        struct Response {
            let reviews: [CourseReview]
            let hasNextPage: Bool
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Load next part reviews
    enum LoadNextReviews {
        struct Request { }

        struct Response {
            let reviews: [CourseReview]
            let hasNextPage: Bool
        }

        struct ViewModel {
            let state: PaginationState
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: ReviewsResult)
    }

    enum PaginationState {
        case result(data: ReviewsResult)
        case error(message: String)
    }
}
