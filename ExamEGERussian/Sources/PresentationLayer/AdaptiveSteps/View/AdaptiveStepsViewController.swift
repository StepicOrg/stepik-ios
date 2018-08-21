//
//  AdaptiveStepsViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 20/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit
import SVProgressHUD

final class AdaptiveStepsViewController: UIViewController {
    var presenter: AdaptiveStepsPresenterProtocol?

    var state: AdaptiveStepsViewState = .idle {
        didSet {
            switch state {
            case .idle:
                SVProgressHUD.dismiss()
            case .fetching:
                SVProgressHUD.show()
            case .error(let message):
                SVProgressHUD.dismiss()
                displayError(with: message)
            }
        }
    }

    private weak var stepView: UIView?

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        presenter?.refresh()
    }

    // MARK: - Private API

    private func setup() {
        view.backgroundColor = .white
    }

    private func displayError(with message: String) {
        presentConfirmationAlert(
            withTitle: NSLocalizedString("Error", comment: ""),
            message: message,
            buttonFirstTitle: NSLocalizedString("Cancel", comment: ""),
            buttonSecondTitle: NSLocalizedString("Try Again", comment: ""),
            secondAction: { [weak self] in
                self?.presenter?.refresh()
            }
        )
    }
}

// MARK: - AdaptiveStepViewController: AdaptiveStepView -

extension AdaptiveStepsViewController: AdaptiveStepsView {
    func addContentController(_ controller: UIViewController) {
        view.addSubview(controller.view)

        stepView = controller.view
        stepView?.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        addChildViewController(controller)
        controller.didMove(toParentViewController: self)
    }

    func removeContentController(_ controller: UIViewController) {
        controller.willMove(toParentViewController: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
    }

    func updateTitle(_ title: String) {
        self.title = title
    }
}
