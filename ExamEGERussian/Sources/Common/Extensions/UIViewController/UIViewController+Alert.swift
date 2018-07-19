//
//  UIViewController+Alert.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

extension UIViewController {

    func presentAlert(withTitle title: String?, message: String? = nil,
                      actionTitle: String? = "Ок".localized,
                      action actionCallback: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .cancel) { _ in
            actionCallback?()
        })
        present(alert, animated: true, completion: nil)
    }

    func presentConfirmationAlert(withTitle title: String?, message: String? = nil,
                                  buttonFirstTitle: String? = "Ок".localized,
                                  buttonSecondTitle: String? = "Cancel".localized,
                                  firstAction: (() -> Void)? = nil, secondAction: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonFirstTitle, style: .default) { _ in
            firstAction?()
        })
        alert.addAction(UIAlertAction(title: buttonSecondTitle, style: .default) { _ in
            secondAction?()
        })
        present(alert, animated: true, completion: nil)
    }

}
