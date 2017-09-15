//
//  LessonViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 18.05.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class LessonViewController: PagerController, ShareableController, LessonView {

    var parentShareBlock: ((UIActivityViewController) -> Void)?

    weak var sectionNavigationDelegate: SectionNavigationDelegate?

    var navigationRules : (prev: Bool, next: Bool)?

    fileprivate var presenter: LessonPresenter?

    lazy var activityView: UIView = self.initActivityView()

    lazy var warningView: UIView = self.initWarningView()

    fileprivate let warningViewTitle = NSLocalizedString("ConnectionErrorText", comment: "")

    fileprivate func initWarningView() -> UIView {
        let v = WarningView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), delegate: self, text: warningViewTitle, image: Images.noWifiImage.size250x250, width: UIScreen.main.bounds.width - 16, contentMode: DeviceInfo.isIPad() ? UIViewContentMode.bottom : UIViewContentMode.scaleAspectFit)
        self.view.insertSubview(v, aboveSubview: self.view)
        v.alignTop("50", leading: "0", bottom: "0", trailing: "0", to: self.view)
        return v
    }

    fileprivate func initActivityView() -> UIView {
        let v = UIView()
        let ai = UIActivityIndicatorView()
        ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        ai.constrainWidth("50", height: "50")
        ai.color = UIColor.mainDark
        v.backgroundColor = UIColor.white
        v.addSubview(ai)
        ai.alignCenter(with: v)
        ai.startAnimating()
        self.view.insertSubview(v, aboveSubview: self.view)
        v.alignTop("50", leading: "0", bottom: "0", trailing: "0", to: self.view)
        v.isHidden = false
        return v
    }

    var doesPresentActivityIndicatorView: Bool = false {
        didSet {
            if doesPresentActivityIndicatorView {
                DispatchQueue.main.async {
                    [weak self] in
                    self?.activityView.isHidden = false
                }
            } else {
                DispatchQueue.main.async {
                    [weak self] in
                    self?.activityView.isHidden = true
                }
            }
        }
    }

    var doesPresentWarningView: Bool = false {
        didSet {
            if doesPresentWarningView {
                DispatchQueue.main.async {
                    [weak self] in
                    self?.warningView.isHidden = false
                }
            } else {
                DispatchQueue.main.async {
                    [weak self] in
                    self?.warningView.isHidden = true
                }
            }
        }
    }

    func updateTitle(title: String) {
        self.navigationItem.title = title
    }

    var initObjects: LessonInitObjects?
    var initIds: LessonInitIds?

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        initTabs()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
//        navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.backBarButtonItem?.title = " "

        presenter = LessonPresenter(objects: initObjects, ids: initIds, stepsAPI: ApiDataDownloader.steps, lessonsAPI: ApiDataDownloader.lessons)
        presenter?.view = self
        presenter?.sectionNavigationDelegate = sectionNavigationDelegate
        if let rules = navigationRules {
            presenter?.shouldNavigateToPrev = rules.prev
            presenter?.shouldNavigateToNext = rules.next
        }
        presenter?.refreshSteps()
    }

    fileprivate func initTabs() {
        tabWidth = 44.0
        tabHeight = 44.0
        indicatorHeight = 2.0
        tabOffset = 8.0
        centerCurrentTab = true
        indicatorColor = UIColor.mainDark
        tabsViewBackgroundColor = UIColor.mainLight
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if navigationController?.delegate === self {
            navigationController?.delegate = nil
        }
    }

    func setRefreshing(refreshing: Bool) {
        if refreshing {
            self.view.isUserInteractionEnabled = false
            self.doesPresentWarningView = false
            self.doesPresentActivityIndicatorView = true
        } else {
            self.view.isUserInteractionEnabled = true
            self.doesPresentActivityIndicatorView = false
            if presenter?.pagesCount == 0 {
                self.doesPresentWarningView = true
            }
        }
    }

    func reload() {
        self.reloadData()
    }

    func selectTab(index: Int, updatePage: Bool) {
        self.selectTabAtIndex(index, swipe: true)
    }

    var nItem: UINavigationItem {
        return self.navigationItem
    }

    var nController: UINavigationController? {
        return self.navigationController
    }

    var pagerGestureRecognizer: UIPanGestureRecognizer? {
        return (self.pageViewController.view.subviews.first as? UIScrollView)?.panGestureRecognizer
    }

    deinit {
        print("deinit LessonViewController")
    }

    func share(popoverSourceItem: UIBarButtonItem?, popoverView: UIView?, fromParent: Bool) {

        guard let url = presenter?.url else {
            return
        }

        let shareBlock: ((UIActivityViewController) -> Void)? = parentShareBlock

        DispatchQueue.global(qos: .background).async {
            [weak self] in
            let shareVC = SharingHelper.getSharingController(url)
            shareVC.popoverPresentationController?.barButtonItem = popoverSourceItem
            shareVC.popoverPresentationController?.sourceView = popoverView
            DispatchQueue.main.async {
                [weak self] in
                if !fromParent {
                    self?.present(shareVC, animated: true, completion: nil)
                } else {
                    shareBlock?(shareVC)
                }
            }
        }
    }

    @available(iOS 9.0, *)
    override var previewActionItems: [UIPreviewActionItem] {
        let shareItem = UIPreviewAction(title: NSLocalizedString("Share", comment: ""), style: .default, handler: {
            [weak self]
            _, _ in
            self?.share(popoverSourceItem: nil, popoverView: nil, fromParent: true)
        })
        return [shareItem]
    }
}

extension LessonViewController: PagerDataSource {
    func numberOfTabs(_ pager: PagerController) -> Int {
        guard let presenter = presenter else { return 0 }
        return presenter.pagesCount
    }

    func tabViewForIndex(_ index: Int, pager: PagerController) -> UIView {
        guard let presenter = presenter else { return UIView() }
        return presenter.tabView(index: index)
    }

    func controllerForTabAtIndex(_ index: Int, pager: PagerController) -> UIViewController {
        guard let presenter = presenter else { return UIViewController() }
        return presenter.controller(index: index) ?? UIViewController()
    }
}

extension LessonViewController: WarningViewDelegate {
    func didPressButton() {
        presenter?.refreshSteps()
    }
}

extension LessonViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let navigation = self.navigationController as? StyledNavigationViewController else {
            return
        }
        if navigation.topViewController != viewController {
            print("wow")
        }
        navigation.animateShadowChange(for: self)
    }
}
