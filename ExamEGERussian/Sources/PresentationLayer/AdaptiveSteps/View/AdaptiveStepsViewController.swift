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

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

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

        view.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - AdaptiveStepViewController: AdaptiveStepView -

extension AdaptiveStepsViewController: AdaptiveStepsView {
    func addContentController(_ controller: UIViewController) {
        addChildViewController(controller)

        stepView = controller.view
        contentView.addSubview(stepView!)
        stepView?.snp.makeConstraints {
            $0.edges.equalTo(contentView)
        }

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
