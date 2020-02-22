import Pageboy
import SnapKit
import Tabman
import UIKit

protocol CodeQuizFullscreenViewControllerProtocol: AnyObject {
    func displayContent(viewModel: CodeQuizFullscreen.ContentLoad.ViewModel)
    func displayCodeReset(viewModel: CodeQuizFullscreen.ResetCode.ViewModel)
    func displayRunCodeTooltip(viewModel: CodeQuizFullscreen.RunCodeTooltipAvailabilityCheck.ViewModel)
}

extension CodeQuizFullscreenViewController {
    enum Appearance {
        static let barTintColor = UIColor.mainDark
        static let barBackgroundColor = UIColor.mainLight
        static let barSeparatorColor = UIColor.gray
        static let barButtonTitleFontNormal = UIFont.systemFont(ofSize: 15, weight: .light)
        static let barButtonTitleFontSelected = UIFont.systemFont(ofSize: 15)
        static let barButtonTitleColor = UIColor.mainDark

        static let spacingBetweenPages: CGFloat = 16.0

        static var navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState {
            .init(shadowViewAlpha: 0.0)
        }
    }

    enum Animation {
        static let runCodeTooltipAppearanceDelay: TimeInterval = 1.0
    }
}

final class CodeQuizFullscreenViewController: TabmanViewController {
    lazy var codeQuizFullscreenView = self.view as? CodeQuizFullscreenView
    lazy var styledNavigationController = self.navigationController as? StyledNavigationController

    private lazy var runCodeTooltip = TooltipFactory.runCode
    private weak var runCodeTooltipAnchorView: UIView?

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

            if labelBarButton.text == CodeQuizFullscreen.Tab.run.title {
                self.runCodeTooltipAnchorView = labelBarButton
            }
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

    private let interactor: CodeQuizFullscreenInteractorProtocol

    private let availableTabs: [CodeQuizFullscreen.Tab]
    private let initialTabIndex: Int

    private var tabViewControllers: [UIViewController?] = []
    // TODO: Refactor to module input
    private var codeQuizFullscreenCodeViewController: CodeQuizFullscreenCodeViewController?
    private var runCodeModuleInput: CodeQuizFullscreenRunCodeInputProtocol?

    private var viewModel: CodeQuizFullscreenViewModel?

    init(
        interactor: CodeQuizFullscreenInteractorProtocol,
        availableTabs: [CodeQuizFullscreen.Tab] = [.instruction, .code],
        initialTab: CodeQuizFullscreen.Tab = .code
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
        let view = CodeQuizFullscreenView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.moreBarButton

        self.dataSource = self
        self.addBar(self.tabBarView, dataSource: self, at: .top)

        self.interPageSpacing = Appearance.spacingBetweenPages
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.styledNavigationController?.changeShadowViewAlpha(
            Appearance.navigationBarAppearance.shadowViewAlpha,
            sender: self
        )
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    // MARK: Private API

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
                return CodeQuizFullscreenInstructionViewController(
                    content: viewModel.content,
                    samples: viewModel.samples,
                    limit: viewModel.limit
                )
            case .code:
                self.codeQuizFullscreenCodeViewController = CodeQuizFullscreenCodeViewController(
                    language: viewModel.language,
                    code: viewModel.code,
                    codeTemplate: viewModel.codeTemplate,
                    delegate: self
                )
                return self.codeQuizFullscreenCodeViewController
            case .run:
                let assembly = CodeQuizFullscreenRunCodeAssembly(
                    stepID: viewModel.stepID,
                    language: viewModel.language
                )

                let viewController = assembly.makeModule()

                self.runCodeModuleInput = assembly.moduleInput
                self.runCodeModuleInput?.update(code: viewModel.code ?? "")
                self.runCodeModuleInput?.update(samples: viewModel.samples)

                return viewController
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

                    let assembly = CodeEditorSettingsLegacyAssembly()
                    let controller = assembly.makeModule()
                    controller.title = NSLocalizedString("Settings", comment: "")

                    strongSelf.navigationController?.pushViewController(controller, animated: true)
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

// MARK: - CodeQuizFullscreenViewController: CodeQuizFullscreenViewControllerProtocol -

extension CodeQuizFullscreenViewController: CodeQuizFullscreenViewControllerProtocol {
    func displayContent(viewModel: CodeQuizFullscreen.ContentLoad.ViewModel) {
        self.viewModel = viewModel.data

        self.runCodeModuleInput?.update(code: viewModel.data.code ?? "")
        self.runCodeModuleInput?.update(samples: viewModel.data.samples)

        self.reloadData()
    }

    func displayCodeReset(viewModel: CodeQuizFullscreen.ResetCode.ViewModel) {
        self.codeQuizFullscreenCodeViewController?.code = viewModel.code
        self.runCodeModuleInput?.update(code: viewModel.code)
    }

    func displayRunCodeTooltip(viewModel: CodeQuizFullscreen.RunCodeTooltipAvailabilityCheck.ViewModel) {
        guard let runCodeTooltipAnchorView = self.runCodeTooltipAnchorView else {
            return
        }

        if viewModel.shouldShowTooltip {
            DispatchQueue.main.asyncAfter(deadline: .now() + Animation.runCodeTooltipAppearanceDelay) {
                self.runCodeTooltip.show(direction: .up, in: self.view, from: runCodeTooltipAnchorView)
            }
        }
    }
}

// MARK: - CodeQuizFullscreenViewController: PageboyViewControllerDataSource -

extension CodeQuizFullscreenViewController: PageboyViewControllerDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        self.availableTabs.count
    }

    func viewController(
        for pageboyViewController: PageboyViewController,
        at index: PageboyViewController.PageIndex
    ) -> UIViewController? {
        self.loadTabViewControllerIfNeeded(at: index)
        return self.tabViewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        .at(index: self.initialTabIndex)
    }
}

// MARK: - CodeQuizFullscreenViewController: TMBarDataSource -

extension CodeQuizFullscreenViewController: TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let title = self.availableTabs[safe: index]?.title ?? ""
        return TMBarItem(title: title)
    }
}

// MARK: - CodeQuizFullscreenViewController: CodeQuizFullscreenCodeViewControllerDelegate -

extension CodeQuizFullscreenViewController: CodeQuizFullscreenCodeViewControllerDelegate {
    func codeQuizFullscreenCodeViewController(
        _ viewController: CodeQuizFullscreenCodeViewController,
        codeDidChange code: String
    ) {
        self.interactor.doReplyUpdate(request: .init(code: code))
        self.runCodeModuleInput?.update(code: code)
    }

    func codeQuizFullscreenCodeViewController(
        _ viewController: CodeQuizFullscreenCodeViewController,
        didSubmitCode code: String
    ) {
        self.interactor.doReplySubmit(request: .init())
        self.dismiss(animated: true)
    }

    func codeQuizFullscreenCodeViewController(
        _ viewController: CodeQuizFullscreenCodeViewController,
        didEndEditingCode code: String
    ) {
        self.runCodeModuleInput?.update(code: code)
        self.interactor.doRunCodeTooltipAvailabilityCheck(request: .init())
    }
}

// MARK: - CodeQuizFullscreenViewController: StyledNavigationControllerPresentable -

extension CodeQuizFullscreenViewController: StyledNavigationControllerPresentable {
    var navigationBarAppearanceOnFirstPresentation: StyledNavigationController.NavigationBarAppearanceState {
        Appearance.navigationBarAppearance
    }
}
