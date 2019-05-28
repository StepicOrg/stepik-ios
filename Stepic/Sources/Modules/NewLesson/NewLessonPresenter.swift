import UIKit

protocol NewLessonPresenterProtocol {
    func presentLesson(response: NewLesson.LessonLoad.Response)
    func presentLessonNavigation(response: NewLesson.LessonNavigationLoad.Response)
}

final class NewLessonPresenter: NewLessonPresenterProtocol {
    weak var viewController: NewLessonViewControllerProtocol?

    func presentLesson(response: NewLesson.LessonLoad.Response) {
        let viewModel: NewLesson.LessonLoad.ViewModel

        switch response.data {
        case .failure:
            viewModel = .init(state: .error)
        case .success(let result):
            viewModel = .init(state: .result(data: self.makeViewModel(lesson: result.0, steps: result.1)))
        }

        self.viewController?.displayLesson(viewModel: viewModel)
    }

    func presentLessonNavigation(response: NewLesson.LessonNavigationLoad.Response) {
        let viewModel = NewLesson.LessonNavigationLoad.ViewModel(
            hasPreviousUnit: response.hasPreviousUnit,
            hasNextUnit: response.hasNextUnit
        )

        self.viewController?.displayLessonNavigation(viewModel: viewModel)
    }

    // MAKE: Private API

    private func makeViewModel(lesson: Lesson, steps: [Step]) -> NewLessonViewModel {
        let lessonTitle = lesson.title
        let steps: [NewLessonViewModel.StepDescription] = steps.map { step in
            let iconImage: UIImage? = {
                switch step.block.name {
                case "video":
                    return UIImage(named: "video_step_icon")
                case "text":
                    return UIImage(named: "theory_step_icon")
                case "code", "dataset", "admin", "sql":
                    return UIImage(named: "code_step_icon")
                default:
                    return UIImage(named: "quiz_step_icon")
                }
            }()
            return (id: step.id, iconImage: iconImage ?? UIImage())
        }
        return NewLessonViewModel(lessonTitle: lessonTitle, steps: steps)
    }
}
