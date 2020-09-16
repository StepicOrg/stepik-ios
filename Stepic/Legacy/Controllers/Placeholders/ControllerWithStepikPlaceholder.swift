//
//  ControllerWithStepikPlaceholder.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 20.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import SnapKit
import UIKit

typealias StepikPlaceholderControllerState = StepikPlaceholderControllerContainer.PlaceholderState

extension StepikPlaceholderControllerContainer {
    struct Appearance {
        var placeholderAppearance = StepikPlaceholderView.Appearance()
    }
}

final class StepikPlaceholderControllerContainer: StepikPlaceholderViewDelegate {
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

    let appearance: Appearance

    lazy var placeholderView: StepikPlaceholderView = {
        let view = StepikPlaceholderView()
        view.appearance = self.appearance.placeholderAppearance
        return view
    }()

    fileprivate var registeredPlaceholders: [PlaceholderState: StepikPlaceholder] = [:]
    fileprivate var currentPlaceholderButtonAction: (() -> Void)?
    fileprivate var isPlaceholderShown: Bool = false

    func buttonDidClick(_ button: UIButton) {
        currentPlaceholderButtonAction?()
    }

    init(appearance: Appearance = Appearance()) {
        self.appearance = appearance
    }
}

protocol ControllerWithStepikPlaceholder: AnyObject {
    var isPlaceholderShown: Bool { get set }
    var placeholderContainer: StepikPlaceholderControllerContainer { get set }

    func registerPlaceholder(placeholder: StepikPlaceholder, for state: StepikPlaceholderControllerState)
    func showPlaceholder(for state: StepikPlaceholderControllerState)
}

extension ControllerWithStepikPlaceholder where Self: UIViewController {
    var isPlaceholderShown: Bool {
        set {
            placeholderContainer.placeholderView.isHidden = !newValue
            placeholderContainer.isPlaceholderShown = newValue
        }
        get {
            placeholderContainer.isPlaceholderShown
        }
    }

    func registerPlaceholder(placeholder: StepikPlaceholder, for state: StepikPlaceholderControllerState) {
        placeholderContainer.registeredPlaceholders[state] = placeholder
    }

    func showPlaceholder(for state: StepikPlaceholderControllerState) {
        guard let placeholder = placeholderContainer.registeredPlaceholders[state] else {
            return
        }

        updatePlaceholderLayout()
        placeholderContainer.placeholderView.set(placeholder: placeholder.style)
        placeholderContainer.placeholderView.delegate = placeholderContainer
        placeholderContainer.currentPlaceholderButtonAction = placeholder.buttonAction

        isPlaceholderShown = true
    }

    private func updatePlaceholderLayout() {
        guard let view = self.view else {
            return
        }

        if placeholderContainer.placeholderView.superview == nil {
            placeholderContainer.placeholderView.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(placeholderContainer.placeholderView)

            placeholderContainer.placeholderView.snp.makeConstraints { $0.center.edges.equalTo(view) }

            placeholderContainer.placeholderView.setNeedsLayout()
            placeholderContainer.placeholderView.layoutIfNeeded()
        }
        view.bringSubviewToFront(placeholderContainer.placeholderView)
    }
}
