//
//  StepikViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 20.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class StepikViewController: UIViewController {

    class PlaceholderState: Equatable, Hashable {
        var id: String

        init(id: String) {
            self.id = id
        }

        static let anonymous = PlaceholderState(id: "anonymous")
        static let connectionError = PlaceholderState(id: "connectionError")

        var hashValue: Int {
            get {
                return id.hashValue
            }
        }

        public static func == (lhs: PlaceholderState, rhs: PlaceholderState) -> Bool {
            return lhs.id == rhs.id
        }
    }

    private var registeredPlaceholders: [PlaceholderState: StepikPlaceholder] = [:]
    private var currentPlaceholderButtonAction: (() -> Void)?

    lazy private var placeholderView: StepikPlaceholderView = {
        let view = StepikPlaceholderView()
        return view
    }()

    var isPlaceholderShown: Bool = false {
        didSet {
            placeholderView.isHidden = !isPlaceholderShown
        }
    }

    func registerPlaceholder(placeholder: StepikPlaceholder, for state: PlaceholderState) {
        registeredPlaceholders[state] = placeholder
    }

    func showPlaceholder(for state: PlaceholderState) {
        guard let placeholder = registeredPlaceholders[state] else {
            return
        }

        updatePlaceholderLayout()
        placeholderView.set(placeholder: placeholder.style)
        placeholderView.delegate = self
        currentPlaceholderButtonAction = placeholder.buttonAction

        isPlaceholderShown = true
    }

    private func updatePlaceholderLayout() {
        if placeholderView.superview == nil {
            placeholderView.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(placeholderView)
            placeholderView.alignCenter(withView: view)
            placeholderView.align(toView: view)

            placeholderView.setNeedsLayout()
            placeholderView.layoutIfNeeded()
        }
        view.bringSubview(toFront: placeholderView)
    }
}

extension StepikViewController: StepikPlaceholderViewDelegate {
    func buttonDidClick(_ button: UIButton) {
        currentPlaceholderButtonAction?()
    }
}
