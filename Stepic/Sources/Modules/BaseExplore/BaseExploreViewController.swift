import UIKit

protocol BaseExploreViewControllerProtocol: class {
    func displayFullscreenCourseList(
        viewModel: BaseExplore.FullscreenCourseListModulePresentation.ViewModel
    )
    func displayCourseInfo(viewModel: BaseExplore.CourseInfoPresentation.ViewModel)
    func displayCourseSyllabus(viewModel: BaseExplore.CourseSyllabusPresentation.ViewModel)
    func displayLastStep(viewModel: BaseExplore.LastStepPresentation.ViewModel)
    func displayAuthorization(viewModel: BaseExplore.AuthorizationPresentation.ViewModel)
    func displayPaidCourseBuying(viewModel: BaseExplore.PaidCourseBuyingPresentation.ViewModel)
}

protocol SubmoduleType: UniqueIdentifiable {
    var position: Int { get }
}

class BaseExploreViewController: UIViewController {
    let interactor: BaseExploreInteractorProtocol
    private var submodules: [Submodule] = []
    lazy var exploreView = self.view as? BaseExploreView

    init(interactor: BaseExploreInteractorProtocol) {
        self.interactor = interactor

        super.init(nibName: nil, bundle: nil)
        self.registerForNotifications()
    }

    // swiftlint:disable:next unavailable_function
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: ViewController lifecycle

    override func loadView() {
        let view = BaseExploreView(frame: UIScreen.main.bounds)
        self.view = view
    }

    // MARK: Modules

    func registerSubmodule(_ submodule: Submodule) {
        self.submodules.append(submodule)

        if let viewController = submodule.viewController {
            self.addChild(viewController)
        }

        // We have contract here:
        // - subviews in exploreView have same position as in corresponding Submodule object
        for module in self.submodules where module.type.position >= submodule.type.position {
            self.exploreView?.insertBlockView(
                submodule.view,
                before: module.view
            )
            return
        }
    }

    func removeLanguageDependentSubmodules() {
        for submodule in self.submodules where submodule.isLanguageDependent {
            self.removeSubmodule(submodule)
        }
    }

    func removeSubmodule(_ submodule: Submodule) {
        self.exploreView?.removeBlockView(submodule.view)
        submodule.viewController?.removeFromParent()
        self.submodules = self.submodules.filter { submodule.view != $0.view }
    }

    func getSubmodule(type: SubmoduleType) -> Submodule? {
        return self.submodules.first(where: { $0.type.uniqueIdentifier == type.uniqueIdentifier })
    }

    final func tryToSetOnlineState(moduleInput: CourseListInputProtocol) {
        self.interactor.doOnlineModeReset(request: .init(modules: [moduleInput]))
    }

    private func registerForNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleRefreshContentAfterLanguageChange),
            name: .contentLanguageDidChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleRefreshContentAfterLoginAndLogout),
            name: .didLogin,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleRefreshContentAfterLoginAndLogout),
            name: .didLogout,
            object: nil
        )
    }

    func refreshContentAfterLanguageChange() {
    }

    func refreshContentAfterLoginAndLogout() {
    }

    @objc
    private func handleRefreshContentAfterLoginAndLogout() {
        self.refreshContentAfterLoginAndLogout()
    }

    @objc
    private func handleRefreshContentAfterLanguageChange() {
        self.refreshContentAfterLoginAndLogout()
    }

    // MARK: - Structs

    struct Submodule {
        let viewController: UIViewController?
        let view: UIView
        let isLanguageDependent: Bool
        let type: SubmoduleType
    }
}

extension BaseExploreViewController: BaseExploreViewControllerProtocol {
    func displayFullscreenCourseList(
        viewModel: BaseExplore.FullscreenCourseListModulePresentation.ViewModel
    ) {
        let assembly = FullscreenCourseListAssembly(
            presentationDescription: viewModel.presentationDescription,
            courseListType: viewModel.courseListType
        )
        let viewController = assembly.makeModule()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func displayCourseInfo(viewModel: BaseExplore.CourseInfoPresentation.ViewModel) {
        let assembly = CourseInfoAssembly(courseID: viewModel.courseID, initialTab: .info)
        let viewController = assembly.makeModule()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func displayCourseSyllabus(viewModel: BaseExplore.CourseSyllabusPresentation.ViewModel) {
        let assembly = CourseInfoAssembly(courseID: viewModel.courseID, initialTab: .syllabus)
        let viewController = assembly.makeModule()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func displayLastStep(viewModel: BaseExplore.LastStepPresentation.ViewModel) {
        guard let navigationController = self.navigationController else {
            return
        }

        LastStepRouter.continueLearning(
            for: viewModel.course,
            isAdaptive: viewModel.isAdaptive,
            using: navigationController
        )
    }

    func displayAuthorization(viewModel: BaseExplore.AuthorizationPresentation.ViewModel) {
        RoutingManager.auth.routeFrom(controller: self, success: nil, cancel: nil)
    }

    func displayPaidCourseBuying(viewModel: BaseExplore.PaidCourseBuyingPresentation.ViewModel) {
        WebControllerManager.sharedManager.presentWebControllerWithURLString(
            viewModel.urlPath,
            inController: self,
            withKey: "paid_course",
            allowsSafari: true,
            backButtonStyle: .done
        )
    }
}
