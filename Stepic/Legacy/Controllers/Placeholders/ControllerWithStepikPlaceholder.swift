import SnapKit
import UIKit

// MARK: - StepikPlaceholderControllerContainer -

typealias StepikPlaceholderControllerState = StepikPlaceholderControllerContainer.PlaceholderState

extension StepikPlaceholderControllerContainer {
    struct Appearance {
        var placeholderAppearance = StepikPlaceholderView.Appearance()
    }
}

final class StepikPlaceholderControllerContainer: StepikPlaceholderViewDelegate {
    let appearance: Appearance

    fileprivate let shouldPinPlaceholderToSafeAreaLayoutGuide: Bool

    lazy var placeholderView: StepikPlaceholderView = {
        let view = StepikPlaceholderView()
        view.appearance = self.appearance.placeholderAppearance
        return view
    }()

    fileprivate var registeredPlaceholders: [PlaceholderState: StepikPlaceholder] = [:]
    fileprivate var currentPlaceholderButtonAction: (() -> Void)?
    fileprivate var isPlaceholderShown = false

    init(
        appearance: Appearance = Appearance(),
        shouldPinPlaceholderToSafeAreaLayoutGuide: Bool = false
    ) {
        self.appearance = appearance
        self.shouldPinPlaceholderToSafeAreaLayoutGuide = shouldPinPlaceholderToSafeAreaLayoutGuide
    }

    func buttonDidClick(_ button: UIButton) {
        self.currentPlaceholderButtonAction?()
    }

    final class PlaceholderState: Hashable {
        static let anonymous = PlaceholderState(id: "anonymous")
        static let connectionError = PlaceholderState(id: "connectionError")
        static let refreshing = PlaceholderState(id: "refreshing")
        static let empty = PlaceholderState(id: "empty")
        static let adaptiveCoursePassed = PlaceholderState(id: "adaptiveCoursePassed")

        var id: String

        init(id: String) {
            self.id = id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
        }

        static func == (lhs: PlaceholderState, rhs: PlaceholderState) -> Bool {
            if lhs === rhs { return true }
            if type(of: lhs) != type(of: rhs) { return false }
            if lhs.id != rhs.id { return false }
            return true
        }
    }
}

// MARK: - ControllerWithStepikPlaceholder: AnyObject -

protocol ControllerWithStepikPlaceholder: AnyObject {
    var isPlaceholderShown: Bool { get set }
    var placeholderContainer: StepikPlaceholderControllerContainer { get set }

    func registerPlaceholder(placeholder: StepikPlaceholder, for state: StepikPlaceholderControllerState)
    func showPlaceholder(for state: StepikPlaceholderControllerState)
}

extension ControllerWithStepikPlaceholder where Self: UIViewController {
    var isPlaceholderShown: Bool {
        set {
            self.placeholderContainer.placeholderView.isHidden = !newValue
            self.placeholderContainer.isPlaceholderShown = newValue
        }
        get {
            self.placeholderContainer.isPlaceholderShown
        }
    }

    func registerPlaceholder(placeholder: StepikPlaceholder, for state: StepikPlaceholderControllerState) {
        self.placeholderContainer.registeredPlaceholders[state] = placeholder
    }

    func showPlaceholder(for state: StepikPlaceholderControllerState) {
        guard let placeholder = self.placeholderContainer.registeredPlaceholders[state] else {
            return
        }

        self.updatePlaceholderLayout()
        self.placeholderContainer.placeholderView.set(placeholder: placeholder.style)
        self.placeholderContainer.placeholderView.delegate = self.placeholderContainer
        self.placeholderContainer.currentPlaceholderButtonAction = placeholder.buttonAction

        self.isPlaceholderShown = true
    }

    private func updatePlaceholderLayout() {
        guard let view = self.view else {
            return
        }

        if self.placeholderContainer.placeholderView.superview == nil {
            self.placeholderContainer.placeholderView.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(self.placeholderContainer.placeholderView)

            if self.placeholderContainer.shouldPinPlaceholderToSafeAreaLayoutGuide {
                self.placeholderContainer.placeholderView.snp.makeConstraints { make in
                    make.center.equalTo(view)
                    make.edges.equalTo(view.safeAreaLayoutGuide)
                }
            }  else {
                self.placeholderContainer.placeholderView.snp.makeConstraints { $0.center.edges.equalTo(view) }
            }

            self.placeholderContainer.placeholderView.setNeedsLayout()
            self.placeholderContainer.placeholderView.layoutIfNeeded()
        }
        view.bringSubviewToFront(self.placeholderContainer.placeholderView)
    }
}
