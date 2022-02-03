import UIKit

protocol CourseListPresenterProtocol: AnyObject {
    func presentCourses(response: CourseList.CoursesLoad.Response)
    func presentNextCourses(response: CourseList.NextCoursesLoad.Response)
    func presentWaitingState(response: CourseList.BlockingWaitingIndicatorUpdate.Response)
}

final class CourseListPresenter: CourseListPresenterProtocol {
    weak var viewController: CourseListViewControllerProtocol?

    func presentCourses(response: CourseList.CoursesLoad.Response) {
        var viewModel: CourseList.CoursesLoad.ViewModel

        let courses = self.makeWidgetViewModels(
            courses: response.result.fetchedCourses.courses,
            availableInAdaptive: response.result.availableAdaptiveCourses,
            isAuthorized: response.isAuthorized,
            isCoursePricesEnabled: response.isCoursePricesEnabled,
            coursePurchaseFlow: response.coursePurchaseFlow,
            viewSource: response.viewSource
        )

        let data = CourseList.ListData(
            courses: courses,
            hasNextPage: response.result.fetchedCourses.hasNextPage
        )
        viewModel = CourseList.CoursesLoad.ViewModel(state: .result(data: data))

        self.viewController?.displayCourses(viewModel: viewModel)
    }

    func presentNextCourses(response: CourseList.NextCoursesLoad.Response) {
        switch response.result {
        case .failure:
            self.viewController?.displayNextCourses(viewModel: .init(state: .error))
        case .success(let data):
            let courses = self.makeWidgetViewModels(
                courses: data.fetchedCourses.courses,
                availableInAdaptive: data.availableAdaptiveCourses,
                isAuthorized: response.isAuthorized,
                isCoursePricesEnabled: response.isCoursePricesEnabled,
                coursePurchaseFlow: response.coursePurchaseFlow,
                viewSource: response.viewSource
            )
            let listData = CourseList.ListData(
                courses: courses,
                hasNextPage: data.fetchedCourses.hasNextPage
            )
            let viewModel = CourseList.NextCoursesLoad.ViewModel(state: .result(data: listData))
            self.viewController?.displayNextCourses(viewModel: viewModel)
        }
    }

    func presentWaitingState(response: CourseList.BlockingWaitingIndicatorUpdate.Response) {
        self.viewController?.displayBlockingLoadingIndicator(viewModel: .init(shouldDismiss: response.shouldDismiss))
    }

    private func makeWidgetViewModels(
        courses: [(UniqueIdentifierType, Course)],
        availableInAdaptive: Set<Course>,
        isAuthorized: Bool,
        isCoursePricesEnabled: Bool,
        coursePurchaseFlow: CoursePurchaseFlowType,
        viewSource: AnalyticsEvent.CourseViewSource
    ) -> [CourseWidgetViewModel] {
        var viewModels: [CourseWidgetViewModel] = []
        for (uid, course) in courses {
            let isAdaptive = availableInAdaptive.contains(course)
            let viewModel = self.makeWidgetViewModel(
                uniqueIdentifier: uid,
                course: course,
                isAdaptive: isAdaptive,
                isAuthorized: isAuthorized,
                isCoursePricesEnabled: isCoursePricesEnabled,
                coursePurchaseFlow: coursePurchaseFlow,
                viewSource: viewSource
            )

            viewModels.append(viewModel)
        }
        return viewModels
    }

    private func makeProgressViewModel(progress: Progress, course: Course) -> CourseWidgetProgressViewModel {
        let progressValue = progress.cost > 0
            ? progress.score / Float(progress.cost)
            : 1
        let certificateRegularThreshold = (course.certificateRegularThreshold ?? 0) > 0
            ? course.certificateRegularThreshold
            : nil
        let certificateDistinctionThreshold = (course.certificateDistinctionThreshold ?? 0) > 0
            ? course.certificateDistinctionThreshold
            : nil

        return CourseWidgetProgressViewModel(
            score: progress.score,
            cost: progress.cost,
            progress: progressValue,
            progressLabelText: "\(FormatterHelper.progressScore(progress.score))/\(progress.cost)",
            isWithCertificate: course.isWithCertificate,
            certificateRegularThreshold: certificateRegularThreshold,
            certificateDistinctionThreshold: certificateDistinctionThreshold
        )
    }

    private func makeWidgetViewModel(
        uniqueIdentifier: UniqueIdentifierType,
        course: Course,
        isAdaptive: Bool,
        isAuthorized: Bool,
        isCoursePricesEnabled: Bool,
        coursePurchaseFlow: CoursePurchaseFlowType,
        viewSource: AnalyticsEvent.CourseViewSource
    ) -> CourseWidgetViewModel {
        let isEnrolled = isAuthorized && course.enrolled

        let summaryText: String = {
            let summary = course.summary.trimmingCharacters(in: .whitespacesAndNewlines)
            return summary.isEmpty
                ? course.courseDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                : summary
        }()

        var progressViewModel: CourseWidgetProgressViewModel?
        if let progress = course.progress {
            progressViewModel = self.makeProgressViewModel(progress: progress, course: course)
        }

        var userCourseViewModel: CourseWidgetUserCourseViewModel?
        if let userCourse = course.userCourse {
            userCourseViewModel = CourseWidgetUserCourseViewModel(
                isFavorite: userCourse.isFavorite,
                isArchived: userCourse.isArchived
            )
        }

        var ratingLabelText: String?
        if let reviewsCount = course.reviewSummary?.count,
           let averageRating = course.reviewSummary?.average,
           reviewsCount > 0 {
            ratingLabelText = FormatterHelper.averageRating(averageRating)
        }

        let certificateLabelText = course.isWithCertificate ? NSLocalizedString("Certificate", comment: "") : nil

        var priceViewModel: CourseWidgetPriceViewModel?
        if isCoursePricesEnabled {
            let priceString: String? = {
                if course.isPaid {
                    switch coursePurchaseFlow {
                    case .web:
                        return course.displayPriceIAP ?? course.displayPrice
                    case .iap:
                        return course.displayPriceTierPrice ?? course.displayPrice
                    }
                }
                return NSLocalizedString("CourseWidgetPriceFree", comment: "")
            }()
            let discountPriceString: String? = {
                guard course.isPaid else {
                    return nil
                }

                switch coursePurchaseFlow {
                case .web:
                    guard let defaultPromoCode = course.defaultPromoCode,
                          defaultPromoCode.isValid && course.priceTier == nil else {
                        return nil
                    }

                    return FormatterHelper.price(defaultPromoCode.price, currencyCode: defaultPromoCode.currencyCode)
                case .iap:
                    return course.displayPriceTierPromo
                }
            }()

            priceViewModel = CourseWidgetPriceViewModel(
                isPaid: course.isPaid,
                isEnrolled: isEnrolled,
                priceString: priceString,
                discountPriceString: discountPriceString
            )
        }

        return CourseWidgetViewModel(
            title: course.title,
            summary: summaryText,
            coverImageURL: URL(string: course.coverURLString),
            learnersLabelText: FormatterHelper.longNumber(course.learnersCount ?? 0),
            ratingLabelText: ratingLabelText,
            certificateLabelText: certificateLabelText,
            isAdaptive: isAdaptive,
            isEnrolled: isEnrolled,
            isWishlisted: course.isInWishlist,
            isWishlistAvailable: isAuthorized && !course.enrolled,
            progress: progressViewModel,
            userCourse: userCourseViewModel,
            price: priceViewModel,
            uniqueIdentifier: uniqueIdentifier,
            courseID: course.id,
            viewSource: viewSource
        )
    }
}
