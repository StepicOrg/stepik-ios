//
//  LessonViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 18.05.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class LessonViewController : RGPageViewController, ShareableController, LessonView {
    
    var parentShareBlock : ((UIActivityViewController) -> (Void))? = nil

    var presenter: LessonPresenter?
    
    lazy var activityView : UIView = self.initActivityView()
    
    lazy var warningView : UIView = self.initWarningView()
    
    let warningViewTitle = NSLocalizedString("ConnectionErrorText", comment: "")
    
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
        ai.color = UIColor.stepicGreenColor()
        v.backgroundColor = UIColor.white
        v.addSubview(ai)
        ai.alignCenter(with: v)
        ai.startAnimating()
        self.view.insertSubview(v, aboveSubview: self.view)
        v.alignTop("50", leading: "0", bottom: "0", trailing: "0", to: self.view)
        v.isHidden = false
        return v
    }

    var doesPresentActivityIndicatorView : Bool = false {
        didSet {
            if doesPresentActivityIndicatorView {
                DispatchQueue.main.async{
                    [weak self] in
                    self?.activityView.isHidden = false
                }
            } else {
                DispatchQueue.main.async{
                    [weak self] in
                    self?.activityView.isHidden = true
                }
            }
        }
    }

    var doesPresentWarningView : Bool = false {
        didSet {
            if doesPresentWarningView {
                DispatchQueue.main.async{
                    [weak self] in
                    self?.warningView.isHidden = false
                }
            } else {
                DispatchQueue.main.async{
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
        datasource = self
        delegate = self
        
        presenter = LessonPresenter(objects: initObjects, ids: initIds)
        presenter?.refreshSteps()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.backBarButtonItem?.title = " "
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
        self.selectTabAtIndex(index, updatePage: true)
    }
    
    var nItem: UINavigationItem {
        return self.navigationItem
    }
    
    var pagerGestureRecognizer: UIPanGestureRecognizer? {
        return pagerScrollView?.panGestureRecognizer
    }
    
    override var pagerOrientation: UIPageViewControllerNavigationOrientation {
        get {
            return .horizontal
        }
    }
    
    override var tabbarPosition: RGTabbarPosition {
        get {
            return .top
        }
    }
    
    override var tabbarStyle: RGTabbarStyle {
        get {
            return RGTabbarStyle.solid
        }
    }
    
    override var tabIndicatorColor: UIColor {
        get {
            return UIColor.white
        }
    }
    
    override var barTintColor: UIColor? {
        get {
            return UIColor.navigationColor
        }
    }
    
    override var tabStyle: RGTabStyle {
        get {
            return .inactiveFaded
        }
    }
    
    override var tabbarWidth: CGFloat {
        get {
            return 44.0
        }
    }
    
    override var tabbarHeight : CGFloat {
        get {
            return 44.0
        }
    }
    
    override var tabMargin: CGFloat {
        get {
            return 8.0
        }
    }
    
    deinit {
        print("deinit LessonViewController")
    }
    
    
    func share(popoverSourceItem: UIBarButtonItem?, popoverView: UIView?, fromParent: Bool) {
        
        guard let url = presenter?.url else {
            return
        }
        
        let shareBlock: ((UIActivityViewController) -> (Void))? = parentShareBlock
        
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
            action, vc in
            self?.share(popoverSourceItem: nil, popoverView: nil, fromParent: true)
        })
        return [shareItem]
    }
}

extension LessonViewController : RGPageViewControllerDataSource {

    public func pageViewController(_ pageViewController: RGPageViewController, tabViewForPageAt index: Int) -> UIView {
        guard let presenter = presenter else { return UIView() }
        return presenter.tabView(index: index)
    }
    
    public func numberOfPages(for pageViewController: RGPageViewController) -> Int {
        guard let presenter = presenter else { return 0 }
        return presenter.pagesCount
    }
    
    public func pageViewController(_ pageViewController: RGPageViewController, viewControllerForPageAt index: Int) -> UIViewController? {
        guard let presenter = presenter else { return nil }
        return presenter.controller(index: index)
    }
}

extension LessonViewController: RGPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: RGPageViewController, widthForTabAt index: Int) -> CGFloat {
        return 44.0
    }
    
    func pageViewController(_ pageViewController: RGPageViewController, heightForTabAt index: Int) -> CGFloat {
        return 44.0
    }
}

extension LessonViewController: WarningViewDelegate {
    func didPressButton() {
        presenter?.refreshSteps()
    }
}

