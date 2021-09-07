import SnapKit
import UIKit

class StyledNavigationController: UINavigationController {
    enum Appearance {
        static let backgroundColor = UIColor.stepikNavigationBarBackground
        static let statusBarColor = UIColor.stepikNavigationBarBackground
        static let tintColor = UIColor.stepikAccent
        static let textColor = UIColor.stepikAccent

        static let titleFont = UIFont.systemFont(ofSize: 17, weight: .regular)

        static let shadowViewColor = UIColor.stepikOpaqueSeparator
        static let shadowViewHeight: CGFloat = 0.5

        static let statusBarStyle = UIStatusBarStyle.default
    }

    struct NavigationBarAppearanceState {
        var shadowViewAlpha: CGFloat
        var backgroundColor: UIColor
        var statusBarColor: UIColor
        var textColor: UIColor
        var tintColor: UIColor
        var statusBarStyle: UIStatusBarStyle

        init(
            shadowViewAlpha: CGFloat = 1.0,
            backgroundColor: UIColor = StyledNavigationController.Appearance.backgroundColor,
            statusBarColor: UIColor = StyledNavigationController.Appearance.statusBarColor,
            textColor: UIColor = StyledNavigationController.Appearance.textColor,
            tintColor: UIColor = StyledNavigationController.Appearance.tintColor,
            statusBarStyle: UIStatusBarStyle = StyledNavigationController.Appearance.statusBarStyle
        ) {
            self.shadowViewAlpha = shadowViewAlpha
            self.backgroundColor = backgroundColor
            self.statusBarColor = statusBarColor
            self.textColor = textColor
            self.tintColor = tintColor
            self.statusBarStyle = statusBarStyle
        }

        static func pageSheetAppearance() -> NavigationBarAppearanceState {
            .init(statusBarColor: .clear)
        }
    }

    override var delegate: UINavigationControllerDelegate? {
        didSet {
            if self.delegate !== self {
                fatalError("To set a delegate use `addDelegate(_:)`")
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        self.statusBarStyle
    }

    private var statusBarStyle = StyledNavigationController.Appearance.statusBarStyle {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    private lazy var statusBarView: UIView = {
        let view = UIView(frame: UIApplication.shared.statusBarFrame)
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var shadowView = UIView()
    private var shadowViewLeadingConstraint: Constraint?
    private var shadowViewTrailingConstraint: Constraint?

    private var lastAction = UINavigationController.Operation.none

    private var navigationBarAppearanceForController: [Int: NavigationBarAppearanceState] = [:]
    private var defaultNavigationBarAppearance = NavigationBarAppearanceState()

    // swiftlint:disable:next weak_delegate
    private var multicastDelegate = MulticastDelegate<UINavigationControllerDelegate>()

    // MARK: ViewController lifecycle & base methods

    override func viewDidLoad() {
        self.delegate = self
        super.viewDidLoad()
        self.setupAppearance()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.statusBarView.frame = UIApplication.shared.statusBarFrame
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(
            alongsideTransition: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.navigationBar.layoutIfNeeded()
                strongSelf.statusBarView.frame = UIApplication.shared.statusBarFrame
            },
            completion: nil
        )
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        self.lastAction = .pop
        return super.popViewController(animated: animated)
    }

    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        self.lastAction = .pop
        return super.popToRootViewController(animated: animated)
    }

    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        self.lastAction = .pop
        return super.popToViewController(viewController, animated: animated)
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        self.lastAction = .push
        super.pushViewController(viewController, animated: animated)
    }

    // MARK: Public API

    /// Triggers a navigation bar appearance update.
    /// See `NavigationBarAppearanceState` for properties that will be updated.
    func setNeedsNavigationBarAppearanceUpdate(sender: UIViewController) {
        let appearance = self.getNavigationBarAppearance(for: sender)

        DispatchQueue.main.async {
            self.changeShadowViewAlpha(appearance.shadowViewAlpha, sender: sender)
            self.changeBackgroundColor(appearance.backgroundColor, sender: sender)
            self.changeStatusBarColor(appearance.statusBarColor, sender: sender)
            self.changeTextColor(appearance.textColor, sender: sender)
            self.changeTintColor(appearance.tintColor, sender: sender)
            self.changeStatusBarStyle(appearance.statusBarStyle, sender: sender)
        }
    }

    /// Sets default navigation bar appearance for the view controllers that will be pushed onto the navigation stack.
    /// - Parameter appearance: The navigation bar appearance that will be used as a default one for view controllers.
    /// If view controller conforms to `StyledNavigationControllerPresentable` protocol than `navigationBarAppearanceOnFirstPresentation`
    /// will be used.
    func setDefaultNavigationBarAppearance(_ appearance: NavigationBarAppearanceState) {
        self.defaultNavigationBarAppearance = appearance
    }

    /// Remove title for "Back" button on top controller
    func removeBackButtonTitleForTopController() {
        // View controller before last in stack
        guard let parentViewController = self.viewControllers.dropLast().last else {
            return
        }

        if #available(iOS 14.0, *) {
            parentViewController.navigationItem.backButtonDisplayMode = .minimal
        } else {
            parentViewController.navigationItem.backBarButtonItem = UIBarButtonItem(
                title: "",
                style: .plain,
                target: nil,
                action: nil
            )
        }
    }

    /// Change color of navigation bar & status bar background
    func changeBackgroundColor(_ color: UIColor, sender: UIViewController) {
        guard sender === self.topViewController else {
            self.navigationBarAppearanceForController[sender.hashValue]?.backgroundColor = color
            self.navigationBarAppearanceForController[sender.hashValue]?.statusBarColor = color
            return
        }

        self.changeBackgroundColor(color)
        self.changeStatusBarColor(color)
    }

    /// Change color of status bar background
    func changeStatusBarColor(_ color: UIColor, sender: UIViewController) {
        guard sender === self.topViewController else {
            self.navigationBarAppearanceForController[sender.hashValue]?.statusBarColor = color
            return
        }
        return self.changeStatusBarColor(color)
    }

    /// Change alpha of shadow view
    func changeShadowViewAlpha(_ alpha: CGFloat, sender: UIViewController) {
        guard sender === self.topViewController else {
            self.navigationBarAppearanceForController[sender.hashValue]?.shadowViewAlpha = alpha
            return
        }
        return self.changeShadowViewAlpha(alpha)
    }

    /// Change navigation bar text color
    func changeTextColor(_ color: UIColor, sender: UIViewController) {
        guard sender === self.topViewController else {
            self.navigationBarAppearanceForController[sender.hashValue]?.textColor = color
            return
        }
        return self.changeTextColor(color)
    }

    /// Change navigation bar tint color
    func changeTintColor(_ color: UIColor, sender: UIViewController) {
        guard sender === self.topViewController else {
            self.navigationBarAppearanceForController[sender.hashValue]?.tintColor = color
            return
        }
        return self.changeTintColor(color)
    }

    /// Change status bar style
    func changeStatusBarStyle(_ style: UIStatusBarStyle, sender: UIViewController) {
        guard sender === self.topViewController else {
            return
        }
        return self.changeStatusBarStyle(style)
    }

    /// Adds an delegate to the delegates collection.
    func addDelegate(_ delegate: UINavigationControllerDelegate) {
        self.multicastDelegate.add(delegate)
    }

    /// Removes an delegate from the delegates collection.
    func removeDelegate(_ delegate: UINavigationControllerDelegate) {
        self.multicastDelegate.remove(delegate)
    }

    // MARK: Private API

    private func changeBackgroundColor(_ color: UIColor) {
        self.navigationBar.isTranslucent = true
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)

        self.navigationBar.backgroundColor = color
        self.statusBarView.backgroundColor = color

        if let topViewController = self.topViewController {
            self.navigationBarAppearanceForController[topViewController.hashValue]?.backgroundColor = color
        }
    }

    private func changeStatusBarColor(_ color: UIColor) {
        self.statusBarView.backgroundColor = color

        if let topViewController = self.topViewController {
            self.navigationBarAppearanceForController[topViewController.hashValue]?.statusBarColor = color
        }
    }

    private func changeShadowViewAlpha(_ alpha: CGFloat) {
        let alpha = self.normalizeAlphaValue(alpha)
        self.navigationBar.shadowImage = UIImage()
        self.shadowView.backgroundColor = Appearance.shadowViewColor.withAlphaComponent(alpha)

        if let topViewController = self.topViewController {
            self.navigationBarAppearanceForController[topViewController.hashValue]?.shadowViewAlpha = alpha
        }
    }

    private func changeTextColor(_ color: UIColor) {
        self.navigationBar.titleTextAttributes = [
            .font: Appearance.titleFont,
            .foregroundColor: color
        ]

        if let topViewController = self.topViewController {
            self.navigationBarAppearanceForController[topViewController.hashValue]?.textColor = color
        }
    }

    private func changeTintColor(_ color: UIColor) {
        self.navigationBar.tintColor = color

        if let topViewController = self.topViewController {
            self.navigationBarAppearanceForController[topViewController.hashValue]?.tintColor = color
        }
    }

    private func changeStatusBarStyle(_ style: UIStatusBarStyle) {
        self.statusBarStyle = style

        if let topViewController = self.topViewController {
            self.navigationBarAppearanceForController[topViewController.hashValue]?.statusBarStyle = style
        }
    }

    private func setupAppearance() {
        self.view.addSubview(self.statusBarView)

        self.navigationBar.addSubview(self.shadowView)
        self.shadowView.translatesAutoresizingMaskIntoConstraints = false
        self.shadowView.snp.makeConstraints { make in
            make.bottom.equalTo(self.navigationBar.snp.bottom)
            make.height.equalTo(Appearance.shadowViewHeight)

            self.shadowViewLeadingConstraint = make.leading.equalToSuperview().constraint
            self.shadowViewTrailingConstraint = make.trailing.equalToSuperview().constraint
        }

        self.changeBackgroundColor(StyledNavigationController.Appearance.backgroundColor)
        self.changeStatusBarColor(StyledNavigationController.Appearance.statusBarColor)
        self.changeTextColor(StyledNavigationController.Appearance.textColor)
        self.changeTintColor(StyledNavigationController.Appearance.tintColor)
        self.changeShadowViewAlpha(1.0)
        self.changeStatusBarStyle(self.statusBarStyle)
    }

    private func normalizeAlphaValue(_ alpha: CGFloat) -> CGFloat {
        max(0.0, min(1.0, alpha))
    }

    private func getNavigationBarAppearance(for viewController: UIViewController) -> NavigationBarAppearanceState {
        if let presentableViewController = viewController as? StyledNavigationControllerPresentable,
           !presentableViewController.shouldSaveAppearanceState {
            return NavigationBarAppearanceState()
        }

        let appearance: NavigationBarAppearanceState = {
            let defaultAppearance: NavigationBarAppearanceState
            if let presentableViewController = viewController as? StyledNavigationControllerPresentable {
                defaultAppearance = presentableViewController.navigationBarAppearanceOnFirstPresentation
            } else {
                defaultAppearance = self.defaultNavigationBarAppearance
            }
            return self.navigationBarAppearanceForController[viewController.hashValue] ?? defaultAppearance
        }()

        self.navigationBarAppearanceForController[viewController.hashValue] = appearance
        return appearance
    }

    private func removeNavigationBarAppearance(for viewController: UIViewController) {
        self.navigationBarAppearanceForController.removeValue(forKey: viewController.hashValue)
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func animateShadowView(transitionCoordinator: UIViewControllerTransitionCoordinator) {
        guard let fromViewController = self.transitionCoordinator?.viewController(forKey: .from),
              let toViewController = self.transitionCoordinator?.viewController(forKey: .to) else {
            return
        }

        let targetControllerAppearance = self.getNavigationBarAppearance(for: toViewController)
        let sourceControllerAppearance = self.getNavigationBarAppearance(for: fromViewController)

        let shouldShadowViewAppear = sourceControllerAppearance.shadowViewAlpha
            < targetControllerAppearance.shadowViewAlpha && sourceControllerAppearance.shadowViewAlpha.isEqual(to: 0.0)
        let shouldShadowViewDisappear = sourceControllerAppearance.shadowViewAlpha
            > targetControllerAppearance.shadowViewAlpha && targetControllerAppearance.shadowViewAlpha.isEqual(to: 0.0)

        let previousLeadingConstraintOffset = self.shadowViewLeadingConstraint?.layoutConstraints.first?.constant ?? 0
        let previousTrailingConstraintOffset = self.shadowViewTrailingConstraint?.layoutConstraints.first?.constant ?? 0

        if self.lastAction == .push {
            if shouldShadowViewAppear {
                self.shadowViewLeadingConstraint?.update(offset: self.navigationBar.frame.width)
                self.shadowViewTrailingConstraint?.update(offset: 0)
            } else if shouldShadowViewDisappear {
                self.shadowViewLeadingConstraint?.update(offset: 0)
                self.shadowViewTrailingConstraint?.update(offset: 0)
            }
        } else if self.lastAction == .pop {
            if shouldShadowViewAppear {
                self.shadowViewLeadingConstraint?.update(offset: 0)
                self.shadowViewTrailingConstraint?.update(offset: -self.navigationBar.frame.width)
            } else if shouldShadowViewDisappear {
                self.shadowViewLeadingConstraint?.update(offset: 0)
                self.shadowViewTrailingConstraint?.update(offset: 0)
            }
        }

        self.navigationBar.setNeedsLayout()
        self.navigationBar.layoutIfNeeded()

        transitionCoordinator.animate(
            alongsideTransition: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }

                if strongSelf.lastAction == .push {
                    if shouldShadowViewAppear {
                        strongSelf.shadowViewLeadingConstraint?.update(offset: 0)
                    } else if shouldShadowViewDisappear {
                        strongSelf.shadowViewTrailingConstraint?.update(offset: -strongSelf.navigationBar.frame.width)
                    }
                } else if strongSelf.lastAction == .pop {
                    if shouldShadowViewAppear {
                        strongSelf.shadowViewTrailingConstraint?.update(offset: 0)
                    } else if shouldShadowViewDisappear {
                        strongSelf.shadowViewLeadingConstraint?.update(offset: strongSelf.navigationBar.frame.width)
                    }
                }
            },
            completion: { [weak self] context in
                guard let strongSelf = self else {
                    return
                }

                if !context.isCancelled {
                    if shouldShadowViewDisappear {
                        // Restore hidden to make possible change alpha
                        strongSelf.shadowViewLeadingConstraint?.update(offset: 0)
                        strongSelf.shadowViewTrailingConstraint?.update(offset: 0)
                    }
                } else {
                    // Reset constraints if cancelled
                    strongSelf.shadowViewLeadingConstraint?.update(offset: previousLeadingConstraintOffset)
                    strongSelf.shadowViewTrailingConstraint?.update(offset: previousTrailingConstraintOffset)
                }
                strongSelf.navigationBar.layoutIfNeeded()
            }
        )
    }
}

// MARK: - StyledNavigationController: UINavigationControllerDelegate -

extension StyledNavigationController: UINavigationControllerDelegate {
    // MARK: Responding to a View Controller Being Shown

    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        self.multicastDelegate.invoke { delegate in
            delegate.navigationController?(navigationController, willShow: viewController, animated: animated)
        }

        let targetControllerAppearance = self.getNavigationBarAppearance(for: viewController)

        guard animated, let fromViewController = self.transitionCoordinator?.viewController(forKey: .from) else {
            self.changeBackgroundColor(targetControllerAppearance.backgroundColor)
            self.changeStatusBarColor(targetControllerAppearance.statusBarColor)
            self.changeShadowViewAlpha(targetControllerAppearance.shadowViewAlpha)
            self.changeTextColor(targetControllerAppearance.textColor)
            self.changeTintColor(targetControllerAppearance.tintColor)
            self.changeStatusBarStyle(targetControllerAppearance.statusBarStyle)

            self.navigationBar.setNeedsLayout()
            self.navigationBar.layoutIfNeeded()

            if self.lastAction == .pop && !self.viewControllers.contains(viewController) {
                self.removeNavigationBarAppearance(for: viewController)
            }
            return
        }

        guard let coordinator = self.transitionCoordinator else {
            return
        }

        self.animateShadowView(transitionCoordinator: coordinator)
        self.changeStatusBarStyle(targetControllerAppearance.statusBarStyle)

        coordinator.animate(
            alongsideTransition: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }

                // change appearance w/o status bar style
                strongSelf.changeBackgroundColor(targetControllerAppearance.backgroundColor)
                strongSelf.changeStatusBarColor(targetControllerAppearance.statusBarColor)
                strongSelf.changeShadowViewAlpha(targetControllerAppearance.shadowViewAlpha)
                strongSelf.changeTextColor(targetControllerAppearance.textColor)
                strongSelf.changeTintColor(targetControllerAppearance.tintColor)
            },
            completion: { [weak self] context in
                guard let strongSelf = self else {
                    return
                }

                if !context.isCancelled {
                    // Workaround for strange bug with titleTextAttributes & non-interactive pop
                    // rdar://37567828
                    strongSelf.changeTextColor(targetControllerAppearance.textColor)
                    strongSelf.navigationBar.setNeedsLayout()
                    strongSelf.navigationBar.layoutIfNeeded()

                    if strongSelf.lastAction == .pop && !strongSelf.viewControllers.contains(viewController) {
                        strongSelf.removeNavigationBarAppearance(for: viewController)
                    }
                } else {
                    // Rollback appearance
                    let sourceControllerAppearance: NavigationBarAppearanceState = {
                        if let navigationController = fromViewController as? UINavigationController,
                           let topViewController = navigationController.topViewController {
                            return strongSelf.getNavigationBarAppearance(for: topViewController)
                        }
                        return strongSelf.getNavigationBarAppearance(for: fromViewController)
                    }()

                    strongSelf.changeBackgroundColor(sourceControllerAppearance.backgroundColor)
                    strongSelf.changeStatusBarColor(sourceControllerAppearance.statusBarColor)
                    strongSelf.changeShadowViewAlpha(sourceControllerAppearance.shadowViewAlpha)
                    strongSelf.changeTextColor(sourceControllerAppearance.textColor)
                    strongSelf.changeTintColor(sourceControllerAppearance.tintColor)
                    strongSelf.changeStatusBarStyle(sourceControllerAppearance.statusBarStyle)
                }
            }
        )
    }

    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        self.multicastDelegate.invoke { delegate in
            delegate.navigationController?(navigationController, didShow: viewController, animated: animated)
        }
    }
}

// MARK: - Default appearance protocol

protocol StyledNavigationControllerPresentable: AnyObject {
    /// Appearance for navigation bar, status bar, etc when controller first time presented
    var navigationBarAppearanceOnFirstPresentation: StyledNavigationController.NavigationBarAppearanceState { get }
    /// Determine whether controller should store appearance state and restore it when return back
    var shouldSaveAppearanceState: Bool { get }
}

extension StyledNavigationControllerPresentable {
    var navigationBarAppearanceOnFirstPresentation: StyledNavigationController.NavigationBarAppearanceState {
        StyledNavigationController.NavigationBarAppearanceState()
    }

    var shouldSaveAppearanceState: Bool { true }
}

// MARK: - Color transition helper

enum ColorTransitionHelper {
    static func makeTransitionColor(
        from sourceColor: UIColor,
        to targetColor: UIColor,
        transitionProgress: CGFloat
    ) -> UIColor {
        let progress = max(0, min(1, transitionProgress))

        var fRed: CGFloat = 0
        var fBlue: CGFloat = 0
        var fGreen: CGFloat = 0
        var fAlpha: CGFloat = 0

        var tRed: CGFloat = 0
        var tBlue: CGFloat = 0
        var tGreen: CGFloat = 0
        var tAlpha: CGFloat = 0

        sourceColor.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        targetColor.getRed(&tRed, green: &tGreen, blue: &tBlue, alpha: &tAlpha)

        let red: CGFloat = (progress * (tRed - fRed)) + fRed
        let green: CGFloat = (progress * (tGreen - fGreen)) + fGreen
        let blue: CGFloat = (progress * (tBlue - fBlue)) + fBlue
        let alpha: CGFloat = (progress * (tAlpha - fAlpha)) + fAlpha

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

// MARK: - UIViewController (StyledNavigationController) -

extension UIViewController {
    var styledNavigationController: StyledNavigationController? {
        self.navigationController as? StyledNavigationController
    }
}
