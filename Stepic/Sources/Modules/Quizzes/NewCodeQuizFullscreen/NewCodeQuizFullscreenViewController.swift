import Pageboy
import SnapKit
import Tabman
import UIKit

// MARK: Appearance -

extension NewCodeQuizFullscreenViewController {
    enum Appearance {
        static let barTintColor = UIColor.mainDark
        static let barBackgroundColor = UIColor.mainLight
        static let barSeparatorColor = UIColor.gray
        static let barButtonTitleFontNormal = UIFont.systemFont(ofSize: 15, weight: .light)
        static let barButtonTitleFontSelected = UIFont.systemFont(ofSize: 15)
        static let barButtonTitleColor = UIColor.mainDark

        static let spacingBetweenPages: CGFloat = 16.0

        static var navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState {
            return .init(shadowViewAlpha: 0.0)
        }
    }
}

// MARK: - NewCodeQuizFullscreenViewControllerProtocol: class -

protocol NewCodeQuizFullscreenViewControllerProtocol: class {
    func displayContent(viewModel: NewCodeQuizFullscreen.ContentLoad.ViewModel)
    func displayCodeReset(viewModel: NewCodeQuizFullscreen.ResetCode.ViewModel)
}

// MARK: - NewCodeQuizFullscreenViewController: TabmanViewController -

final class NewCodeQuizFullscreenViewController: TabmanViewController {
    private lazy var tabBarView: TMBar = {
        let bar = TMBarView<TMHorizontalBarLayout, TMLabelBarButton, TMLineBarIndicator>()
        bar.layout.transitionStyle = .snap
        bar.tintColor = Appearance.barTintColor
        bar.backgroundView.style = .flat(color: Appearance.barBackgroundColor)
        bar.indicator.tintColor = Appearance.barTintColor
        bar.indicator.weight = .light
        bar.layout.interButtonSpacing = 0
        bar.layout.contentMode = .fit

        bar.buttons.customize { labelBarButton in
            labelBarButton.font = Appearance.barButtonTitleFontNormal
            labelBarButton.selectedFont = Appearance.barButtonTitleFontSelected
            labelBarButton.tintColor = Appearance.barButtonTitleColor
            labelBarButton.selectedTintColor = Appearance.barButtonTitleColor
        }

        let separatorView = UIView()
        separatorView.backgroundColor = Appearance.barSeparatorColor
        bar.backgroundView.addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1.0 / UIScreen.main.nativeScale)
            make.leading.trailing.bottom.equalToSuperview()
        }

        return bar
    }()

    private lazy var moreBarButton = UIBarButtonItem(
        image: UIImage(named: "horizontal-dots-icon")?.withRenderingMode(.alwaysTemplate),
        style: .plain,
        target: self,
        action: #selector(self.actionButtonClicked)
    )

    private let interactor: NewCodeQuizFullscreenInteractorProtocol

    private let availableTabs: [NewCodeQuizFullscreen.Tab]
    private let initialTabIndex: Int

    private var tabViewControllers: [UIViewController?] = []
    // TODO: Refactor
    private var newCodeQuizFullscreenCodeViewController: NewCodeQuizFullscreenCodeViewController?

    private var viewModel: NewCodeQuizFullscreenViewModel?

    init(
        interactor: NewCodeQuizFullscreenInteractorProtocol,
        availableTabs: [NewCodeQuizFullscreen.Tab] = [.instruction, .code],
        initialTab: NewCodeQuizFullscreen.Tab = .code
    ) {
        self.interactor = interactor

        self.availableTabs = availableTabs
        self.tabViewControllers = Array(repeating: nil, count: availableTabs.count)

        if let initialTabIndex = self.availableTabs.firstIndex(of: initialTab) {
            self.initialTabIndex = initialTabIndex
        } else {
            self.initialTabIndex = 0
        }

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewCodeQuizFullscreenView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.moreBarButton

        self.dataSource = self
        self.addBar(self.tabBarView, dataSource: self, at: .top)

        self.interPageSpacing = Appearance.spacingBetweenPages
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        assert(
            self.navigationController != nil,
            "\(NewCodeQuizFullscreenViewController.self) must be presented in a \(UINavigationController.self)"
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateNavigationBarAppearance()
    }

    // MARK: Private API

    private func updateNavigationBarAppearance() {
        if let styledNavigationController = self.navigationController as? StyledNavigationController {
            styledNavigationController.changeShadowViewAlpha(
                Appearance.navigationBarAppearance.shadowViewAlpha,
                sender: self
            )
        }
    }

    private func loadTabViewControllerIfNeeded(at index: Int) {
        guard self.tabViewControllers.count > index else {
            fatalError("Invalid controllers initialization")
        }

        guard self.tabViewControllers[index] == nil else {
            return
        }

        guard let tab = self.availableTabs[safe: index],
              let viewModel = self.viewModel else {
            return
        }

        let controller: UIViewController? = {
            switch tab {
            case .instruction:
                return NewCodeQuizFullscreenInstructionViewController(
                    content: viewModel.content,
                    samples: viewModel.samples,
                    limit: viewModel.limit
                )
            case .code:
                self.newCodeQuizFullscreenCodeViewController = NewCodeQuizFullscreenCodeViewController(
                    language: viewModel.language,
                    code: viewModel.code,
                    codeTemplate: viewModel.codeTemplate,
                    delegate: self
                )
                return self.newCodeQuizFullscreenCodeViewController
            case .run:
                return nil
            }
        }()

        self.tabViewControllers[index] = controller
    }

    @objc
    private func actionButtonClicked() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Settings", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    guard let strongSelf = self else {
                        return
                    }

                    if #available(iOS 13.0, *) {
                        let assembly = CodeEditorSettingsLegacyAssembly(
                            appearance: .init(
                                navigationBarAppearance: .init(statusBarColor: .clear)
                            )
                        )
                        let controller = assembly.makeModule()
                        controller.title = NSLocalizedString("Settings", comment: "")

                        strongSelf.present(
                            module: controller,
                            embedInNavigation: true,
                            modalPresentationStyle: .automatic
                        )
                    } else {
                        let controller = CodeEditorSettingsLegacyAssembly().makeModule()
                        controller.title = NSLocalizedString("Settings", comment: "")

                        strongSelf.present(
                            module: controller,
                            embedInNavigation: true,
                            modalPresentationStyle: .fullScreen
                        )
                    }
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Reset", comment: ""),
                style: .destructive,
                handler: { [weak self] _ in
                    self?.presentCodeResetAlert()
                }
            )
        )
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        )
        alert.popoverPresentationController?.barButtonItem = self.moreBarButton
        self.present(alert, animated: true, completion: nil)
    }

    private func presentCodeResetAlert() {
        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("ResetAlertDescription", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Reset", comment: ""),
                style: .destructive,
                handler: { [weak self] _ in
                    self?.interactor.doCodeReset(request: .init())
                }
            )
        )
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - NewCodeQuizFullscreenViewController: NewCodeQuizFullscreenViewControllerProtocol -

extension NewCodeQuizFullscreenViewController: NewCodeQuizFullscreenViewControllerProtocol {
    func displayContent(viewModel: NewCodeQuizFullscreen.ContentLoad.ViewModel) {
        self.viewModel = viewModel.data
        self.reloadData()
    }

    func displayCodeReset(viewModel: NewCodeQuizFullscreen.ResetCode.ViewModel) {
        self.newCodeQuizFullscreenCodeViewController?.code = viewModel.code
    }
}

// MARK: - NewCodeQuizFullscreenViewController: PageboyViewControllerDataSource -

extension NewCodeQuizFullscreenViewController: PageboyViewControllerDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return self.availableTabs.count
    }

    func viewController(
        for pageboyViewController: PageboyViewController,
        at index: PageboyViewController.PageIndex
    ) -> UIViewController? {
        self.loadTabViewControllerIfNeeded(at: index)
        return self.tabViewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return .at(index: self.initialTabIndex)
    }
}

// MARK: - NewCodeQuizFullscreenViewController: TMBarDataSource -

extension NewCodeQuizFullscreenViewController: TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let title = self.availableTabs[safe: index]?.title ?? ""
        return TMBarItem(title: title)
    }
}

// MARK: - NewCodeQuizFullscreenViewController: NewCodeQuizFullscreenCodeViewControllerDelegate -

extension NewCodeQuizFullscreenViewController: NewCodeQuizFullscreenCodeViewControllerDelegate {
    func newCodeQuizFullscreenCodeViewController(
        _ viewController: NewCodeQuizFullscreenCodeViewController,
        codeDidChange code: String
    ) {
        self.interactor.doReplyUpdate(request: .init(code: code))
    }

    func newCodeQuizFullscreenCodeViewController(
        _ viewController: NewCodeQuizFullscreenCodeViewController,
        didSubmitCode code: String
    ) {
        self.interactor.doReplySubmit(request: .init())
        self.dismiss(animated: true)
    }
}

// MARK: - NewCodeQuizFullscreenViewController: StyledNavigationControllerPresentable -

extension NewCodeQuizFullscreenViewController: StyledNavigationControllerPresentable {
    var navigationBarAppearanceOnFirstPresentation: StyledNavigationController.NavigationBarAppearanceState {
        return Appearance.navigationBarAppearance
    }
}
