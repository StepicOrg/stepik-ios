import UIKit

protocol NewProfileCreatedCoursesViewControllerProtocol: AnyObject {
    func displayCourses(viewModel: NewProfileCreatedCourses.CoursesLoad.ViewModel)
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
}

extension NewProfileCreatedCoursesViewController: NewProfileCreatedCoursesViewControllerProtocol {
    func displayCourses(viewModel: NewProfileCreatedCourses.CoursesLoad.ViewModel) {
        self.teacherID = viewModel.teacherID
        self.refreshSubmodule()
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
