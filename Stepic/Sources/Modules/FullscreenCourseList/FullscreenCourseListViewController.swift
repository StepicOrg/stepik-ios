import UIKit

protocol FullscreenCourseListViewControllerProtocol: AnyObject {
    func displayCourseInfo(viewModel: FullscreenCourseList.CourseInfoPresentation.ViewModel)
    func displayCourseSyllabus(viewModel: FullscreenCourseList.CourseSyllabusPresentation.ViewModel)
    func displayLastStep(viewModel: FullscreenCourseList.LastStepPresentation.ViewModel)
    func displayAuthorization(viewModel: FullscreenCourseList.PresentAuthorization.ViewModel)
    func displayPlaceholder(viewModel: FullscreenCourseList.PresentPlaceholder.ViewModel)
    func displayPaidCourseBuying(viewModel: FullscreenCourseList.PaidCourseBuyingPresentation.ViewModel)
}

final class FullscreenCourseListViewController: UIViewController, ControllerWithStepikPlaceholder {
    let interactor: FullscreenCourseListInteractorProtocol
    private let courseListType: CourseListType
    private let presentationDescription: CourseList.PresentationDescription?
    private let courseViewSource: AnalyticsEvent.CourseViewSource

    lazy var fullscreenCourseListView = self.view as? FullscreenCourseListView
    private var submoduleViewController: UIViewController?

    private lazy var courseListFilterBarButtonItem = UIBarButtonItem(
        image: UIImage(named: "course-list-filter-slider")?.withRenderingMode(.alwaysTemplate),
        style: .plain,
        target: self,
        action: #selector(self.courseListFilterBarButtonItemClicked)
    )

    var placeholderContainer = StepikPlaceholderControllerContainer()

    init(
        interactor: FullscreenCourseListInteractorProtocol,
        courseListType: CourseListType,
        presentationDescription: CourseList.PresentationDescription?,
        courseViewSource: AnalyticsEvent.CourseViewSource
    ) {
        self.interactor = interactor
        self.presentationDescription = presentationDescription
        self.courseListType = courseListType
        self.courseViewSource = courseViewSource

        super.init(nibName: nil, bundle: nil)

        if self.presentationDescription?.headerViewDescription != nil {
            self.title = NSLocalizedString("RecommendedCategory", comment: "")
        } else {
            self.title = NSLocalizedString("AllCourses", comment: "")
        }

        if self.presentationDescription?.courseListFilterDescription != nil {
            self.navigationItem.rightBarButtonItem = self.courseListFilterBarButtonItem
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ViewController lifecycle

    override func loadView() {
        let view = FullscreenCourseListView(frame: UIScreen.main.bounds)
        self.view = view
        self.refreshSubmodule()

        // Register placeholders
        // Error
        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .noConnection,
                action: { [weak self] in
                    self?.refreshSubmodule()
                }
            ),
            for: .connectionError
        )

        // Empty
        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .emptySearch,
                action: { [weak self] in
                    self?.refreshSubmodule()
                }
            ),
            for: .empty
        )
    }

    // MARK: Private API

    private func refreshSubmodule() {
        self.submoduleViewController?.removeFromParent()

        let courseListAssembly = VerticalCourseListAssembly(
            type: self.courseListType,
            colorMode: .light,
            courseViewSource: self.courseViewSource,
            presentationDescription: self.presentationDescription,
            output: self.interactor
        )
        let courseListViewController = courseListAssembly.makeModule()
        self.addChild(courseListViewController)

        self.submoduleViewController = courseListViewController

        self.fullscreenCourseListView?.attachContentView(
            courseListViewController.view
        )

        if let moduleInput = courseListAssembly.moduleInput {
            self.interactor.doOnlineModeReset(request: .init(module: moduleInput))
        }
    }

    @objc
    private func courseListFilterBarButtonItemClicked() {
        guard let presentationDescription = self.presentationDescription?.courseListFilterDescription else {
            return
        }

        let assembly = CourseListFilterAssembly(
            presentationDescription: presentationDescription,
            output: nil
        )
        let controller = StyledNavigationController(rootViewController: assembly.makeModule())

        self.present(module: controller, embedInNavigation: false, modalPresentationStyle: .stepikAutomatic)
    }
}

extension FullscreenCourseListViewController: FullscreenCourseListViewControllerProtocol {
    func displayPlaceholder(viewModel: FullscreenCourseList.PresentPlaceholder.ViewModel) {
        switch viewModel.state {
        case .error:
            self.showPlaceholder(for: .connectionError)
        case .empty:
            self.showPlaceholder(for: .empty)
        }
    }

    func displayCourseInfo(viewModel: FullscreenCourseList.CourseInfoPresentation.ViewModel) {
        let assembly = CourseInfoAssembly(
            courseID: viewModel.courseID,
            initialTab: .info,
            courseViewSource: viewModel.courseViewSource
        )
        let viewController = assembly.makeModule()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func displayCourseSyllabus(viewModel: FullscreenCourseList.CourseSyllabusPresentation.ViewModel) {
        let assembly = CourseInfoAssembly(
            courseID: viewModel.courseID,
            initialTab: .syllabus,
            courseViewSource: viewModel.courseViewSource
        )
        let viewController = assembly.makeModule()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func displayLastStep(viewModel: FullscreenCourseList.LastStepPresentation.ViewModel) {
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

    func displayAuthorization(viewModel: FullscreenCourseList.PresentAuthorization.ViewModel) {
        RoutingManager.auth.routeFrom(controller: self, success: nil, cancel: nil)
    }

    func displayPaidCourseBuying(viewModel: FullscreenCourseList.PaidCourseBuyingPresentation.ViewModel) {
        WebControllerManager.shared.presentWebControllerWithURLString(
            viewModel.urlPath,
            inController: self,
            withKey: .paidCourse,
            allowsSafari: true,
            backButtonStyle: .done
        )
    }
}
