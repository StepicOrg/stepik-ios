//
//  AdaptiveStepsViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 20/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

final class AdaptiveStepsViewController: UIViewController, ControllerWithStepikPlaceholder {
    var presenter: AdaptiveStepsPresenterProtocol?

    var state: AdaptiveStepsViewState = .idle {
        didSet {
            switch state {
            case .idle:
                isPlaceholderShown = false
                setToolbarItemsEnabled(true)
            case .fetching:
                isPlaceholderShown = false
                setToolbarItemsEnabled(false)
            case .coursePassed:
                showPlaceholder(for: .adaptiveCoursePassed)
                setToolbarItemsEnabled(false)
            case .connectionError:
                showPlaceholder(for: .connectionError)
                setToolbarItemsEnabled(false)
            }
        }
    }

    var placeholderContainer = StepikPlaceholderControllerContainer()

    private weak var stepView: UIView?

    private lazy var hardBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(title: NSLocalizedString("AdaptiveHardReaction", comment: ""), style: .plain,
                        target: self, action: #selector(onHardClick(_:)))
    }()
    private lazy var easyBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(title: NSLocalizedString("AdaptiveEasyReaction", comment: ""), style: .plain,
                        target: self, action: #selector(onEasyClick(_:)))
    }()

    private lazy var submitBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(title: NSLocalizedString("Submit", comment: ""), style: .plain,
                        target: self, action: #selector(onSubmitClick(_:)))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        presenter?.refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
    }

    // MARK: - Private API

    private func setup() {
        view.backgroundColor = .white

        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                     target: self, action: nil)
        toolbarItems = [hardBarButtonItem, spacer, submitBarButtonItem, spacer,
                        easyBarButtonItem]

        registerPlaceholder(placeholder: StepikPlaceholder(.noConnectionQuiz, action: { [weak self] in
            self?.presenter?.refresh()
        }), for: .connectionError)
        registerPlaceholder(placeholder: StepikPlaceholder(.adaptiveCoursePassed), for: .adaptiveCoursePassed)
    }

    private func setToolbarItemsEnabled(_ enabled: Bool) {
        toolbarItems?.forEach {
            $0.isEnabled = enabled
        }
    }

    @objc
    private func onHardClick(_ sender: Any) {
        presenter?.sendHardReaction()
    }

    @objc
    private func onSubmitClick(_ sender: Any) {
        presenter?.submit()
    }

    @objc
    private func onEasyClick(_ sender: Any) {
        presenter?.sendEasyReaction()
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

    func updateSubmitButtonTitle(_ title: String) {
        submitBarButtonItem.title = title
    }
}
