import UIKit

struct CourseWidgetProgressViewModel {
    let progress: Float
    let progressLabelText: String
}

struct CourseWidgetUserCourseViewModel {
    let isFavorite: Bool
    let isArchived: Bool
}

struct CourseWidgetPriceViewModel {
    let isPaid: Bool
    let isEnrolled: Bool
    let priceString: String?
    let discountPriceString: String?
}

struct CourseWidgetViewModel: UniqueIdentifiable {
    let title: String
    let summary: String
    let coverImageURL: URL?
    let learnersLabelText: String
    let ratingLabelText: String?
    let certificateLabelText: String?
    let isAdaptive: Bool
    let isEnrolled: Bool
    let isWishlisted: Bool
    let isWishlistAvailable: Bool
    let progress: CourseWidgetProgressViewModel?
    let userCourse: CourseWidgetUserCourseViewModel?
    let price: CourseWidgetPriceViewModel?
    let uniqueIdentifier: UniqueIdentifierType
    let courseID: Course.IdType
    let viewSource: AnalyticsEvent.CourseViewSource
}
