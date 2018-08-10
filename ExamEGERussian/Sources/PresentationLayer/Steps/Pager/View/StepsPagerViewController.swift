//
//  StepsPagerViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 31/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit
import SVProgressHUD

final class StepsPagerViewController: PagerController, StepsPagerView {
    private struct Theme {
        static let tabHeight: CGFloat = 44.0
        static let tabWidth: CGFloat = 44.0
        static let indicatorHeight: CGFloat = 2.0
        static let tabOffset: CGFloat = 8.0
        static let shadowViewHeight: CGFloat = 0.5
    }

    var state: StepsPagerViewState = .idle {
        didSet {
            switch state {
            case .idle:
                SVProgressHUD.dismiss()
            case .fetching:
                SVProgressHUD.show()
            case .fetched(let steps):
                SVProgressHUD.dismiss()
                setSteps(steps)
            case .error(let message):
                SVProgressHUD.dismiss()
                displayError(with: message)
            }
        }
    }

    var presenter: StepsPagerPresenter?
    private var strongDataSource: StepsPagerDataSource?

    /// Constructs a new `StepsPagerViewController` with strong reference to the data source.
    ///
    /// - Parameter strongDataSource: Sets a strong reference to the data source of kind `StepsPagerDataSource`.
    init(strongDataSource: StepsPagerDataSource) {
        self.strongDataSource = strongDataSource
        super.init(nibName: nil, bundle: nil)
        self.dataSource = self.strongDataSource
    }

    /// Constructs a new `StepsPagerViewController` with weak reference to the data source.
    ///
    /// - Parameter weakDataSource: Sets a weak reference to the data source of kind `StepsPagerDataSource`.
    init(weakDataSource: StepsPagerDataSource) {
        super.init(nibName: nil, bundle: nil)
        self.dataSource = weakDataSource
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        presenter?.refresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.showBottomHairline()
    }

    override func makeConstraints() {
        self.tabsView!.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view)
            make.height.equalTo(Theme.tabHeight)
        }

        self.contentView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(self.tabsView!.snp.bottom)
            make.bottom.equalTo(self.view)
        }

        let shadowView = UIView()
        self.contentView.addSubview(shadowView)
        shadowView.backgroundColor = .lightGray
        shadowView.snp.makeConstraints { make in
            make.height.equalTo(Theme.shadowViewHeight)
            make.top.equalTo(contentView)
            make.leading.trailing.equalTo(contentView)
        }
    }
}

// MARK: - StepsPagerViewController (Actions) -

extension StepsPagerViewController {
    @objc private func shareBarButtonItemDidPressed(_ sender: Any) {
        presenter?.selectShareStep(at: activeTabIndex)
    }
}

// MARK: - StepsPagerViewController (UI Configuration) -

extension StepsPagerViewController {
    private func setup() {
        edgesForExtendedLayout = [.left, .right, .bottom]
        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.hideBottomHairline()

        let shareBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareBarButtonItemDidPressed(_:))
        )
        navigationItem.rightBarButtonItem = shareBarButtonItem

        view.backgroundColor = .white
        setupTabs()
    }

    private func setupTabs() {
        indicatorColor = .mainDark
        tabsViewBackgroundColor = .white

        tabHeight = Theme.tabHeight
        tabWidth = Theme.tabWidth
        indicatorHeight = Theme.indicatorHeight
        tabOffset = Theme.tabOffset

        centerCurrentTab = true
        fixLaterTabsPosition = true
    }
}

// MARK: - StepsPagerViewController (Private API) -

extension StepsPagerViewController {
    private func setSteps(_ steps: [StepPlainObject]) {
        guard let dataSource = dataSource as? StepsPagerDataSource else {
            return print("StepsPagerDataSource doesn't exists")
        }

        dataSource.setSteps(steps)
        reloadData()
    }

    private func displayError(with message: String) {
        presentConfirmationAlert(
            withTitle: NSLocalizedString("Error", comment: ""),
            message: message,
            buttonFirstTitle: NSLocalizedString("Cancel", comment: ""),
            buttonSecondTitle: NSLocalizedString("Try Again", comment: ""),
            firstAction: { [weak self] in
                self?.presenter?.cancel()
            },
            secondAction: { [weak self] in
                self?.presenter?.refresh()
            }
        )
    }
}

// MARK: - UINavigationBar+hideBottomHairline -

private extension UINavigationBar {
    func hideBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.isHidden = true
    }

    func showBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.isHidden = false
    }

    private func hairlineImageViewInNavigationBar(_ view: UIView) -> UIImageView? {
        if let view = view as? UIImageView, view.bounds.size.height <= 1.0 {
            return view
        }

        let subviews = (view.subviews as [UIView])
        for subview: UIView in subviews {
            if let imageView: UIImageView = hairlineImageViewInNavigationBar(subview) {
                return imageView
            }
        }

        return nil
    }
}
