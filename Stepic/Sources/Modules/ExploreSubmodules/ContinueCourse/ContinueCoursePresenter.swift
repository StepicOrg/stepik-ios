import UIKit

protocol ContinueCoursePresenterProtocol {
    func presentLastCourse(response: ContinueCourse.LastCourseLoad.Response)
    func presentTooltip(response: ContinueCourse.TooltipAvailabilityCheck.Response)
}

final class ContinueCoursePresenter: ContinueCoursePresenterProtocol {
    weak var viewController: ContinueCourseViewControllerProtocol?

    func presentLastCourse(response: ContinueCourse.LastCourseLoad.Response) {
        var viewModel: ContinueCourse.LastCourseLoad.ViewModel

        viewModel = ContinueCourse.LastCourseLoad.ViewModel(
            state: .result(data: self.makeViewModel(course: response.result))
        )

        self.viewController?.displayLastCourse(viewModel: viewModel)
    }

    func presentTooltip(response: ContinueCourse.TooltipAvailabilityCheck.Response) {
        self.viewController?.displayTooltip(
            viewModel: .init(shouldShowTooltip: response.shouldShowTooltip)
        )
    }

    private func makeViewModel(course: Course) -> ContinueCourseViewModel {
        let progress: ContinueCourseViewModel.ProgressDescription = {
            if let progress = course.progress {
                var normalizedPercent = progress.percentPassed
                normalizedPercent.round(.up)

                let progressText = String(
                    format: NSLocalizedString("ContinueCourseCourseCurrentProgressTitle", comment: ""),
                    arguments: ["\(FormatterHelper.progressScore(progress.score))", "\(progress.cost)"]
                )

                return (description: progressText, value: normalizedPercent / 100)
            }
            return nil
        }()

        return ContinueCourseViewModel(
            title: course.title,
            coverImageURL: URL(string: course.coverURLString),
            progress: progress
        )
    }
}
