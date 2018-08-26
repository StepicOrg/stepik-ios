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

    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = UIColor(hex: 0x999999)
        pageControl.pageIndicatorTintColor = UIColor(hex: 0xE5E5E5)
        pageControl.addTarget(self, action: #selector(onPageChanged(_:)), for: .touchUpInside)

        return pageControl
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

    override func makeConstraints() {
        tabsView?.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view)
            make.height.equalTo(0)
        }
        tabsView?.isHidden = true

        contentView.snp.makeConstraints {
            $0.edges.equalTo(self.view)
        }

        view.insertSubview(pageControl, aboveSubview: contentView)
        pageControl.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self.view)
        }
    }

    func setTabSelected(_ selected: Bool, at index: Int) {
        guard index < tabCount,
              let subview = tabs[index]?.subviews.first(where: { $0 is StepTabView }),
              let stepTabView = subview as? StepTabView else {
            return
        }

        stepTabView.setTab(selected: selected, animated: true)
    }

    // MARK: - Private API -

    private func setup() {
        delegate = self
        tabHeight = 0
        tabWidth = 0
        indicatorHeight = 0

        let shareBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareBarButtonItemDidPressed(_:))
        )
        navigationItem.rightBarButtonItem = shareBarButtonItem
    }

    private func setSteps(_ steps: [StepPlainObject]) {
        guard let dataSource = dataSource as? StepsPagerDataSource else {
            return print("StepsPagerDataSource doesn't exists")
        }

        dataSource.setSteps(steps)
        reloadData()

        pageControl.numberOfPages = steps.count
        pageControl.currentPage = activeTabIndex
    }

    private func displayError(with message: String) {
        presentConfirmationAlert(
            withTitle: NSLocalizedString("Error", comment: ""),
            message: message,
            buttonFirstTitle: NSLocalizedString("Cancel", comment: ""),
            buttonSecondTitle: NSLocalizedString("TryAgain", comment: ""),
            firstAction: { [weak self] in
                self?.presenter?.cancel()
            },
            secondAction: { [weak self] in
                self?.presenter?.refresh()
            }
        )
    }
}

// MARK: - StepsPagerViewController (Actions) -

extension StepsPagerViewController {
    @objc
    private func shareBarButtonItemDidPressed(_ sender: Any) {
        presenter?.selectShareStep(at: activeTabIndex)
    }

    @objc
    private func onPageChanged(_ sender: Any) {
        selectTabAtIndex(pageControl.currentPage)
    }
}

// MARK: - StepsPagerViewController: PagerDelegate -

extension StepsPagerViewController: PagerDelegate {
    func didChangeTabToIndex(_ pager: PagerController, index: Int) {
        pageControl.currentPage = index
        presenter?.selectStep(at: index)
    }
}
