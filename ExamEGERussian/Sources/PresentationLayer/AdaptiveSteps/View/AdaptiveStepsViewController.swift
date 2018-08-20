//
//  AdaptiveStepsViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 20/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

final class AdaptiveStepsViewController: UIViewController {
    var presenter: AdaptiveStepsPresenterProtocol?
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
