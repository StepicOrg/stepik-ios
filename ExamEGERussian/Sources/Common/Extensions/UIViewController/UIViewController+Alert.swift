//
//  UIViewController+Alert.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

extension UIViewController {
    private var isVisible: Bool {
        return isViewLoaded && view.window != nil
    }

    func presentAlert(
        withTitle title: String?,
        message: String? = nil,
        actionTitle: String? = NSLocalizedString("Ок", comment: ""),
        action actionCallback: (() -> Void)? = nil,
        presentCompletion completion: (() -> Void)? = nil
    ) {
        guard isVisible else {
            return
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .cancel) { _ in
            actionCallback?()
        })
        present(alert, animated: true, completion: completion)
    }

    func presentConfirmationAlert(
        withTitle title: String?,
        message: String? = nil,
        buttonFirstTitle: String? = NSLocalizedString("Ок", comment: ""),
        buttonSecondTitle: String? = NSLocalizedString("Cancel", comment: ""),
        firstAction: (() -> Void)? = nil,
        secondAction: (() -> Void)? = nil,
        presentCompletion completion: (() -> Void)? = nil
    ) {
        guard isVisible else {
            return
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonFirstTitle, style: .default) { _ in
            firstAction?()
        })
        alert.addAction(UIAlertAction(title: buttonSecondTitle, style: .default) { _ in
            secondAction?()
        })
        present(alert, animated: true, completion: completion)
    }
}
