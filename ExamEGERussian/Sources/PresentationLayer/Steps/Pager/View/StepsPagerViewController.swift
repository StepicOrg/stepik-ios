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
        static let warningViewSize: CGSize = CGSize(width: 100.0, height: 100.0)
        static let warningViewOffsetTop: CGFloat = warningViewSize.height / 2.0
    }

    var state: StepsPagerViewState = .idle {
        didSet {
            switch state {
            case .idle:
                SVProgressHUD.dismiss()
            case .fetching:
                SVProgressHUD.show()
            case .fetched(let steps):
                SVProgressHUD.showSuccess(withStatus: nil)
                setSteps(steps)
            case .error:
                SVProgressHUD.dismiss()
            }

            updateWarningView(with: state)
        }
    }

    var presenter: StepsPagerPresenter?
    private var strongDataSource: StepsPagerDataSource?

    private lazy var warningView: WarningView = {
        let warningView = WarningView(
            frame: CGRect(origin: .zero, size: Theme.warningViewSize),
            delegate: self,
            text: "",
            image: Images.noWifiImage.size250x250,
            width: UIScreen.main.bounds.width - 16,
            contentMode: DeviceInfo.current.isPad ? .bottom : .scaleAspectFit
        )

        return warningView
    }()

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

        view.insertSubview(warningView, aboveSubview: view)
        warningView.snp.makeConstraints { make in
            make.top.equalTo(self.tabsView!.snp.bottom).offset(Theme.warningViewOffsetTop)
            make.leading.bottom.trailing.equalTo(self.view)
        }
    }
}

// MARK: - StepsPagerViewController (UI Configuration) -

extension StepsPagerViewController {
    private func setup() {
        edgesForExtendedLayout = [.left, .right, .bottom]
        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.hideBottomHairline()

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

    private func updateWarningView(with state: StepsPagerViewState) {
        switch state {
        case .idle, .fetching, .fetched:
            warningView.isHidden = true
        case .error(let message):
            warningView.isHidden = false
            warningView.text = message
        }
    }
}

// MARK: - StepsPagerViewController: WarningViewDelegate -

extension StepsPagerViewController: WarningViewDelegate {
    func didPressButton() {
        presenter?.refresh()
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
