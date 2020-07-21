import UIKit

protocol NewProfileCreatedCoursesViewControllerProtocol: AnyObject {
    func displayCourses(viewModel: NewProfileCreatedCourses.CoursesLoad.ViewModel)
    func displayCourseInfo(viewModel: NewProfileCreatedCourses.CourseInfoPresentation.ViewModel)
    func displayCourseSyllabus(viewModel: NewProfileCreatedCourses.CourseSyllabusPresentation.ViewModel)
    func displayLastStep(viewModel: NewProfileCreatedCourses.LastStepPresentation.ViewModel)
    func displayAuthorization(viewModel: NewProfileCreatedCourses.PresentAuthorization.ViewModel)
}

final class NewProfileCreatedCoursesViewController: UIViewController {
    private let interactor: NewProfileCreatedCoursesInteractorProtocol

    private var teacherID: User.IdType?
    private var submoduleViewController: UIViewController?

    init(interactor: NewProfileCreatedCoursesInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewProfileCreatedCoursesView(frame: UIScreen.main.bounds)
        self.view = view
    }

    private func refreshSubmodule() {
        self.submoduleViewController?.removeFromParent()

        guard let teacherID = self.teacherID else {
            return
        }

        let courseListAssembly = HorizontalCourseListAssembly(
            type: TeacherCourseListType(teacherID: teacherID),
            colorMode: .clear,
            courseViewSource: .profile(id: teacherID),
            output: self.interactor as? CourseListOutputProtocol
        )
        let courseListViewController = courseListAssembly.makeModule()
        self.addChild(courseListViewController)

        self.submoduleViewController = courseListViewController

        if let profileCreatedCoursesView = self.view as? NewProfileCreatedCoursesView {
            profileCreatedCoursesView.attachContentView(courseListViewController.view)
        }

        if let moduleInput = courseListAssembly.moduleInput {
            self.interactor.doOnlineModeReset(request: .init(module: moduleInput))
        }
    }
}

extension NewProfileCreatedCoursesViewController: NewProfileCreatedCoursesViewControllerProtocol {
    func displayCourses(viewModel: NewProfileCreatedCourses.CoursesLoad.ViewModel) {
        self.teacherID = viewModel.teacherID
        self.refreshSubmodule()
    }

    func displayCourseInfo(viewModel: NewProfileCreatedCourses.CourseInfoPresentation.ViewModel) {
        let assembly = CourseInfoAssembly(
            courseID: viewModel.courseID,
            initialTab: .info,
            courseViewSource: viewModel.courseViewSource
        )
        let viewController = assembly.makeModule()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func displayCourseSyllabus(viewModel: NewProfileCreatedCourses.CourseSyllabusPresentation.ViewModel) {
        let assembly = CourseInfoAssembly(
            courseID: viewModel.courseID,
            initialTab: .syllabus,
            courseViewSource: viewModel.courseViewSource
        )
        let viewController = assembly.makeModule()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func displayLastStep(viewModel: NewProfileCreatedCourses.LastStepPresentation.ViewModel) {
        guard let navigationController = self.navigationController else {
            return
        }

        LastStepRouter.continueLearning(
            for: viewModel.course,
            isAdaptive: viewModel.isAdaptive,
            using: navigationController,
            courseViewSource: viewModel.courseViewSource
        )
    }

    func displayAuthorization(viewModel: NewProfileCreatedCourses.PresentAuthorization.ViewModel) {
        RoutingManager.auth.routeFrom(controller: self, success: nil, cancel: nil)
    }
}
