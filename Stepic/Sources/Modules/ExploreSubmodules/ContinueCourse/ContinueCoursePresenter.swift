import UIKit

protocol ContinueCoursePresenterProtocol {
    func presentLastCourse(response: ContinueCourse.LastCourseLoad.Response)
    func presentTooltip(response: ContinueCourse.TooltipAvailabilityCheck.Response)
}

final class ContinueCoursePresenter: ContinueCoursePresenterProtocol {
    weak var viewController: ContinueCourseViewControllerProtocol?

    func presentLastCourse(response: ContinueCourse.LastCourseLoad.Response) {
        switch response.result {
        case .success(let course):
            let viewModel = self.makeViewModel(course: course)
            self.viewController?.displayLastCourse(viewModel: .init(state: .result(data: viewModel)))
        case .failure(let error):
            if case ContinueCourseInteractor.Error.noLastCourse = error {
                self.viewController?.displayLastCourse(viewModel: .init(state: .empty))
            }
        }
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
