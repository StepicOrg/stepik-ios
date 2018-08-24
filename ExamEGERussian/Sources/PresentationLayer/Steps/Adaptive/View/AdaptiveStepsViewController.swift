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

final class AdaptiveStepsViewController: UIViewController, ControllerWithStepikPlaceholder {
    var presenter: AdaptiveStepsPresenterProtocol?

    var state: AdaptiveStepsViewState = .idle {
        didSet {
            switch state {
            case .idle:
                SVProgressHUD.dismiss()
                isPlaceholderShown = false
            case .fetching:
                SVProgressHUD.show()
                isPlaceholderShown = false
            case .coursePassed:
                SVProgressHUD.dismiss()
                showPlaceholder(for: .adaptiveCoursePassed)
            case .connectionError:
                SVProgressHUD.dismiss()
                showPlaceholder(for: .connectionError)
            }
        }
    }

    var placeholderContainer = StepikPlaceholderControllerContainer()

    private weak var stepView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        presenter?.refresh()
    }

    private func setup() {
        view.backgroundColor = .white

        registerPlaceholder(placeholder: StepikPlaceholder(.noConnectionQuiz, action: { [weak self] in
            self?.presenter?.refresh()
        }), for: .connectionError)
        registerPlaceholder(placeholder: StepikPlaceholder(.adaptiveCoursePassed), for: .adaptiveCoursePassed)
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
