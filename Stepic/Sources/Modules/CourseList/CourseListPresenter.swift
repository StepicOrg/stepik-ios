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
                viewSource: viewSource
            )

            viewModels.append(viewModel)
        }
        return viewModels
    }

    private func makeProgressViewModel(progress: Progress) -> CourseWidgetProgressViewModel {
        var normalizedPercent = progress.percentPassed
        normalizedPercent.round(.up)

        return CourseWidgetProgressViewModel(
            progress: normalizedPercent / 100.0,
            progressLabelText: "\(progress.score)/\(progress.cost)"
        )
    }

    private func makeWidgetViewModel(
        uniqueIdentifier: UniqueIdentifierType,
        course: Course,
        isAdaptive: Bool,
        isAuthorized: Bool,
        viewSource: AnalyticsEvent.CourseViewSource
    ) -> CourseWidgetViewModel {
        let summaryText: String = {
            let summary = course.summary.trimmingCharacters(in: .whitespacesAndNewlines)
            return summary.isEmpty
                ? course.courseDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                : summary
        }()

        var progressViewModel: CourseWidgetProgressViewModel?
        if let progress = course.progress {
            progressViewModel = self.makeProgressViewModel(progress: progress)
        }

        var ratingLabelText: String?
        if let reviewsCount = course.reviewSummary?.count,
           let averageRating = course.reviewSummary?.average,
           reviewsCount > 0 {
            ratingLabelText = FormatterHelper.averageRating(averageRating)
        }

        return CourseWidgetViewModel(
            title: course.title,
            summary: summaryText,
            coverImageURL: URL(string: course.coverURLString),
            learnersLabelText: FormatterHelper.longNumber(course.learnersCount ?? 0),
            ratingLabelText: ratingLabelText,
            isAdaptive: isAdaptive,
            isEnrolled: isAuthorized && course.enrolled,
            progress: progressViewModel,
            uniqueIdentifier: uniqueIdentifier,
            courseID: course.id,
            viewSource: viewSource
        )
    }
}
