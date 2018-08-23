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

    private lazy var hardBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(title: NSLocalizedString("Hard", comment: ""), style: .plain,
                        target: self, action: #selector(onHardClick(_:)))
    }()
    private lazy var easyBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(title: NSLocalizedString("Easy", comment: ""), style: .plain,
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

    private func setupToolbar() {
        let spacer = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: self,
    }

    @objc
    private func onHardClick(_ sender: Any) {
        print("\(#function)")
    }

    @objc
    private func onTaskControlClick(_ sender: Any) {
        print("\(#function)")
    }

    @objc
    private func onEasyClick(_ sender: Any) {
        print("\(#function)")
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
