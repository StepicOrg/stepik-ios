import Pageboy
import SnapKit
import Tabman
import UIKit

protocol NewCodeQuizFullscreenViewControllerProtocol: class {
    func displaySomeActionResult(viewModel: NewCodeQuizFullscreen.SomeAction.ViewModel)
}

final class NewCodeQuizFullscreenViewController: TabmanViewController {
    enum Appearance {
        static let barTintColor = UIColor.mainDark
        static let barBackgroundColor = UIColor.mainLight
        static let barSeparatorColor = UIColor.gray
        static let barButtonTitleFontNormal = UIFont.systemFont(ofSize: 15, weight: .light)
        static let barButtonTitleFontSelected = UIFont.systemFont(ofSize: 15)
        static let barButtonTitleColor = UIColor.mainDark
    }

    private let interactor: NewCodeQuizFullscreenInteractorProtocol

    private let availableTabs: [NewCodeQuizFullscreen.Tab]
    private let initialTabIndex: Int

    private var tabViewControllers: [UIViewController?] = []

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

        self.title = "Title"
        self.view.backgroundColor = .white

        self.navigationItem.rightBarButtonItem = self.moreBarButton

        self.dataSource = self
        self.addBar(self.tabBarView, dataSource: self, at: .top)

        if let styledNavigationController = self.navigationController as? StyledNavigationController {
            DispatchQueue.main.async {
                styledNavigationController.changeShadowViewAlpha(0.0, sender: self)
            }
        }

        self.interactor.doSomeAction(request: .init())
    }

    // MARK: Private API

    private func loadTabViewControllerIfNeeded(at index: Int) {
        guard let viewModel = self.viewModel else {
            return
        }

        guard self.tabViewControllers[index] == nil else {
            return
        }

        guard let tab = self.availableTabs[safe: index] else {
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
                return NewCodeQuizFullscreenCodeViewController(
                    language: viewModel.language,
                    code: viewModel.code,
                    codeTemplate: viewModel.codeTemplate,
                    codeEditorTheme: viewModel.codeEditorTheme
                )
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
                title: NSLocalizedString("SelectLanguage", comment: ""),
                style: .default,
                handler: { _ in
                    print("Select language")
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Reset", comment: ""),
                style: .destructive,
                handler: { _ in
                    print("Reset")
                }
            )
        )
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        )
        alert.popoverPresentationController?.barButtonItem = self.moreBarButton
        self.present(module: alert)
    }
}

extension NewCodeQuizFullscreenViewController: NewCodeQuizFullscreenViewControllerProtocol {
    func displaySomeActionResult(viewModel: NewCodeQuizFullscreen.SomeAction.ViewModel) {
        self.viewModel = viewModel.data
        self.reloadData()
    }
}

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

extension NewCodeQuizFullscreenViewController: TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let title = self.availableTabs[safe: index]?.title ?? ""
        return TMBarItem(title: title)
    }
}
