//
//  ViewPager.swift
//  Pager
//
//  Created by Lucas Oceano on 12/03/2015.
//  Copyright (c) 2015 Cheesecake. All rights reserved.
//
import Foundation
import UIKit.UITableView
import FLKAutoLayout

// MARK: - Pager Enums
//Enum for the location of the tab bar
public enum PagerTabLocation: Int {
    case none = 0 // None will go to the bottom
    case top = 1
    case bottom = 2
}

//Enum for the animation of the tab indicator
public enum PagerAnimation: Int {
    case none = 0 // No animation
    case end = 1 // pager indicator will animate after the VC changes
    case during = 2 // pager indicator will animate as the VC changes
}

// MARK: - Protocols
@objc public protocol PagerDelegate: NSObjectProtocol {
    @objc optional func didChangeTabToIndex(_ pager: PagerController, index: Int)
    @objc optional func didChangeTabToIndex(_ pager: PagerController, index: Int, previousIndex: Int)
    @objc optional func didChangeTabToIndex(_ pager: PagerController, index: Int, previousIndex: Int, swipe: Bool)
}

@objc public protocol PagerDataSource: NSObjectProtocol {
    @objc optional func numberOfTabs(_ pager: PagerController) -> Int
    @objc optional func tabViewForIndex(_ index: Int, pager: PagerController) -> UIView
    @objc optional func viewForTabAtIndex(_ index: Int, pager: PagerController) -> UIView
    @objc optional func controllerForTabAtIndex(_ index: Int, pager: PagerController) -> UIViewController
}

open class PagerController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {

    // MARK: - public properties
    open var contentViewBackgroundColor: UIColor = UIColor.white
    open var indicatorColor: UIColor = UIColor.red
    open var tabsViewBackgroundColor: UIColor = UIColor.gray
    open var tabsTextColor: UIColor = UIColor.white
    open var selectedTabTextColor = UIColor.white
    open var tabsImageViewContentMode = UIViewContentMode.scaleAspectFit
    open weak var dataSource: PagerDataSource?
    open weak var delegate: PagerDelegate?
    open var tabHeight: CGFloat = 44.0
    open var tabTopOffset: CGFloat = 0.0
    open var tabOffset: CGFloat = 56.0
    open var tabWidth: CGFloat = 128.0
    open var tabsTextFont: UIFont = UIFont.boldSystemFont(ofSize: 16.0)
    open var indicatorHeight: CGFloat = 5.0
    open var tabLocation: PagerTabLocation = PagerTabLocation.top
    open var animation: PagerAnimation = PagerAnimation.during
    open var startFromSecondTab: Bool = false
    open var centerCurrentTab: Bool = false
    open var fixFormerTabsPositions: Bool = false
    open var fixLaterTabsPosition: Bool = false
    open var ignoreTopBarHeight: Bool = false
    open var ignoreBottomBarHeight: Bool = false
    fileprivate var tabViews: [UIView] = []
    fileprivate var tabControllers: [UIViewController] = []

    // MARK: - Tab and content stuff
    internal var tabsView: UIScrollView?
    open var pageViewController: UIPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    internal weak var actualDelegate: UIScrollViewDelegate?
    internal var contentView: UIView {
        let contentView = self.pageViewController.view
        contentView!.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView!.backgroundColor = self.contentViewBackgroundColor
        contentView!.bounds = self.view.bounds
        contentView!.tag = 34
        return contentView!
    }

    // MARK: - Tab and content cache
    internal var underlineStroke: UIView = UIView()
    internal var tabs: [UIView?] = []
    internal var contents: [UIViewController?] = []
    internal var tabCount: Int = 0
    internal var activeTabIndex: Int = 0
    internal var activeContentIndex: Int = 0
    internal var animatingToTab: Bool = false
    internal var defaultSetupDone: Bool = false
    internal var didTapOnTabView: Bool = false

    // MARK: - Important Methods
    // Initializing PagerController with Name of the Tabs and their respective ViewControllers
    open func setupPager(tabNames: [String], tabControllers: [UIViewController]) {
        let tabViews = tabNames.map { title -> UILabel in
            let label = UILabel()
            label.text = title
            label.textColor = tabsTextColor
            label.font = tabsTextFont
            label.backgroundColor = .clear
            label.sizeToFit()
            return label
        }
        setupPager(views: tabViews, tabControllers: tabControllers)
    }

    open func setupPager(tabImages: [UIImage], tabControllers: [UIViewController]) {
        let tabViews = tabImages.map { image -> UIImageView in
            let imageView = UIImageView(image: image)
            imageView.contentMode = tabsImageViewContentMode
            imageView.backgroundColor = .clear
            return imageView
        }
        setupPager(views: tabViews, tabControllers: tabControllers)
    }

    open func setupPager(views: [UIView], tabControllers: [UIViewController]) {
        self.tabViews = views
        self.tabControllers = tabControllers
    }

    open func reloadData() {
        self.defaultSetup()
        self.view.setNeedsDisplay()
    }

    open func selectTabAtIndex(_ index: Int) {
        self.selectTabAtIndex(index, swipe: false)
    }

    // MARK: - Other Methods
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.defaultSettings()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !self.defaultSetupDone {
            self.defaultSetup()
        }
    }

    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.changeActiveTabIndex(self.activeTabIndex)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Private Methods
    func defaultSettings() {
        for view in self.pageViewController.view?.subviews ?? [] {
            if let view = view as? UIScrollView {
                self.actualDelegate = view.delegate
                view.delegate = self
            }
        }

        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
    }

    func defaultSetup() {
        // Empty tabs and contents
        for tabView in self.tabs {
            tabView?.removeFromSuperview()
        }

        self.tabs.removeAll(keepingCapacity: true)
        self.contents.removeAll(keepingCapacity: true)
        self.underlineStroke.removeFromSuperview()

        // Get tabCount from dataSource

        if let dataSource = self.dataSource,
            let num = dataSource.numberOfTabs?(self) {
            self.tabCount = num
        } else {
            self.tabCount = tabControllers.count
        }

        // Populate arrays with nil
        self.tabs = Array(repeating: nil, count: self.tabCount)
        for _ in 0 ..< self.tabCount {
            self.tabs.append(nil)
        }

        self.contents = Array(repeating: nil, count: self.tabCount)
        for _ in 0 ..< self.tabCount {
            self.contents.append(nil)
        }

        // Add tabsView
        if self.tabsView == nil {

            self.tabsView = UIScrollView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.tabHeight))
            self.tabsView?.autoresizingMask = .flexibleWidth
            self.tabsView?.backgroundColor = self.tabsViewBackgroundColor
            self.tabsView?.scrollsToTop = false
            self.tabsView?.bounces = false
            self.tabsView?.showsHorizontalScrollIndicator = false
            self.tabsView?.showsVerticalScrollIndicator = false
            self.tabsView?.isScrollEnabled = true
            self.tabsView?.tag = 38

            if self.tabsView != nil {
                self.view.insertSubview(self.tabsView!, at: 0)
            }
        } else {
            self.tabsView = self.view.viewWithTag(38) as? UIScrollView
        }

        // Add tab views to _tabsView
        var contentSizeWidth: CGFloat = 0.0

        // Give the standard offset if fixFormerTabsPositions is provided as YES
        if let tabsView = self.tabsView {
            if self.fixFormerTabsPositions {
                // And if the centerCurrentTab is provided as YES fine tune the offset according to it
                if self.centerCurrentTab {
                    contentSizeWidth = (tabsView.frame.width - self.tabWidth) / 2.0
                } else {
                    contentSizeWidth = self.tabOffset
                }
            }
        }

        for i in 0 ..< self.tabCount {
            if let tabView = self.tabViewAtIndex(i) {
                var frame: CGRect = tabView.frame
                frame.origin.x = contentSizeWidth
                frame.size.width = self.tabWidth
                tabView.frame = frame

                self.tabsView?.addSubview(tabView)

                contentSizeWidth += tabView.frame.width

                // To capture tap events
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PagerController.handleTapGesture(_:)))
                tabView.addGestureRecognizer(tapGestureRecognizer)
            }
        }

        // Extend contentSizeWidth if fixLatterTabsPositions is provided YES
        if self.fixLaterTabsPosition {
            // And if the centerCurrentTab is provided as YES fine tune the content size according to it
            if let tabsView = self.tabsView {
                if self.centerCurrentTab {
                    contentSizeWidth += (tabsView.frame.width - self.tabWidth) / 2.0
                } else {
                    contentSizeWidth += tabsView.frame.width - self.tabWidth - self.tabOffset
                }
            }
        }

        self.tabsView?.contentSize = CGSize(width: contentSizeWidth, height: self.tabHeight)

        self.addChildViewController(self.pageViewController)
        self.view.insertSubview(self.contentView, at: 0)
        // Select starting tab
        let index: Int = self.startFromSecondTab ? 1 : 0
        self.selectTabAtIndex(index, swipe: true)

        if self.tabCount > 0 {
            // creates the indicator
            if let tabViewAtIndex = self.tabViewAtIndex(self.activeContentIndex) {
                var rect: CGRect = tabViewAtIndex.frame
                rect.origin.y = rect.size.height - self.indicatorHeight
                rect.size.height = self.indicatorHeight

                self.underlineStroke = UIView(frame: rect)
                self.underlineStroke.backgroundColor = self.indicatorColor
                self.tabsView?.addSubview(self.underlineStroke)
            }
        }

        self.contentView.alignLeading("0", trailing: "0", toView: self.view)
        self.contentView.constrainTopSpace(toView: self.tabsView!, predicate: "-22")
        self.contentView.alignBottomEdge(withView: self.view, predicate: "0")
        _ = self.tabsView?.alignTop("0", leading: "0", toView: self.view)
        _ = self.tabsView?.alignTrailingEdge(withView: self.view, predicate: "0")
        _ = self.tabsView?.constrainHeight("44")

        let shadowView = UIView()
        self.contentView.addSubview(shadowView)
        shadowView.backgroundColor = UIColor.lightGray
        _ = shadowView.constrainHeight("0.5")
        _ = shadowView.alignTopEdge(withView: contentView, predicate: "22")
        _ = shadowView.alignLeadingEdge(withView: contentView, predicate: "0")
        _ = shadowView.alignTrailingEdge(withView: contentView, predicate: "0")

        // Set setup done
        self.defaultSetupDone = true
    }

    func indexForViewController(_ viewController: UIViewController) -> Int {
        for (index, element) in self.contents.enumerated() {
            if element == viewController {
                return index
            }
        }
        return 0
    }

    func selectTabAtIndex(_ index: Int, swipe: Bool) {
        if index >= self.tabCount {
            return
        }

        self.didTapOnTabView = !swipe
        self.animatingToTab = true

        let previousIndex: Int = self.activeTabIndex

        self.changeActiveTabIndex(index)
        self.setActiveContentIndex(index)

        if let delegate = self.delegate {
            if delegate.responds(to: #selector(PagerDelegate.didChangeTabToIndex(_: index:))) {
                delegate.didChangeTabToIndex!(self, index: index)
            } else if delegate.responds(to: #selector(PagerDelegate.didChangeTabToIndex(_: index: previousIndex:))) {
                delegate.didChangeTabToIndex!(self, index: index, previousIndex: previousIndex)
            } else if delegate.responds(to: #selector(PagerDelegate.didChangeTabToIndex(_: index: previousIndex: swipe:))) {
                delegate.didChangeTabToIndex!(self, index: index, previousIndex: previousIndex, swipe: swipe)
            }
        }

        // Updating selected tab color
        updateSelectedTab(index)
    }

    func updateSelectedTab(_ index: Int) {

        let selectedTab = self.tabViewAtIndex(index)

        // Resetting all tab colors to white
        for tab in self.tabs {
            if tab != selectedTab {
                if let label = tab?.subviews.first as? UILabel {
                    label.textColor = tabsTextColor
                }

//                UIView.animate(withDuration: 0.1){
                    tab?.alpha = 0.566
//                }
            }

        }

        // Setting current selected tab to red
        if let label = selectedTab?.subviews.first as? UILabel {
            label.textColor = selectedTabTextColor
        }
//        UIView.animate(withDuration: 0.1){
            selectedTab?.alpha = 1.0
//        }
    }

    func changeActiveTabIndex(_ newIndex: Int) {

        if newIndex == self.activeTabIndex {
            return
        }

        self.activeTabIndex = newIndex

        guard let tabView: UIView = self.tabViewAtIndex(self.activeTabIndex),
              let tabsView = self.tabsView else {
            return
        }

        var frame: CGRect = tabView.frame

        if self.centerCurrentTab {

            if (frame.origin.x + frame.width + (tabsView.frame.width / 2)) >= tabsView.contentSize.width {
                frame.origin.x = (tabsView.contentSize.width - tabsView.frame.width)
            } else {

                frame.origin.x += (frame.width / 2)
                frame.origin.x -= (tabsView.frame.width / 2)

                if frame.origin.x < 0 {
                    frame.origin.x = 0
                }

            }

        } else {
            frame.origin.x -= self.tabOffset
            frame.size.width = tabsView.frame.width
        }

        if frame.origin.x >= 0 && frame.origin.x <= tabsView.contentSize.width {
            tabsView.setContentOffset(frame.origin, animated: true)
        }
    }

    func tabViewAtIndex(_ index: Int) -> TabView? {
        guard
            let dataSource = self.dataSource,
            index < self.tabCount
            else {
                return nil
        }

        if (self.tabs[index] as UIView?) == nil {

            var tabViewContent = UIView()
            if let tab = dataSource.tabViewForIndex?(index, pager: self) {
                tabViewContent = tab
            } else {
                tabViewContent = tabViews[index]
            }
            tabViewContent.autoresizingMask = [.flexibleHeight, .flexibleWidth]

            let tabView: TabView = TabView(frame: CGRect(x: 0.0, y: 0.0, width: self.tabWidth, height: self.tabHeight))
            tabView.addSubview(tabViewContent)
            tabView.clipsToBounds = true
            tabViewContent.center = tabView.center

            // Replace the null object with tabView
            self.tabs[index] = tabView
        }

        return self.tabs[index] as? TabView
    }

    func setNeedsReloadOptions() {
        guard let tabsView = self.tabsView else {
            return
        }

        // We should update contentSize property of our tabsView, so we should recalculate it with the new values
        var contentSizeWidth: CGFloat = 0.0

        // Give the standard offset if fixFormerTabsPositions is provided as YES
        if self.fixFormerTabsPositions {
            // And if the centerCurrentTab is provided as YES fine tune the offset according to it
            if self.centerCurrentTab {
                contentSizeWidth = (tabsView.frame.width - self.tabWidth) / 2.0
            } else {
                contentSizeWidth = self.tabOffset
            }
        }

        // Update every tab's frame
        for i in 0 ..< self.tabCount {
            if let tabView = self.tabViewAtIndex(i) {
                var frame: CGRect = tabView.frame
                frame.origin.x = contentSizeWidth
                frame.size.width = self.tabWidth
                tabView.frame = frame
                contentSizeWidth += tabView.frame.width
            }
        }

        // Extend contentSizeWidth if fixLatterTabsPositions is provided YES
        if self.fixLaterTabsPosition {

            // And if the centerCurrentTab is provided as YES fine tune the content size according to it
            if self.centerCurrentTab {
                contentSizeWidth += (tabsView.frame.width - self.tabWidth) / 2.0
            } else {
                contentSizeWidth += tabsView.frame.width - self.tabWidth - self.tabOffset
            }
        }
        // Update tabsView's contentSize with the new width
        tabsView.contentSize = CGSize(width: contentSizeWidth, height: self.tabHeight)
    }

    func viewControllerAtIndex(_ index: Int) -> UIViewController? {
        guard
            let dataSource = self.dataSource,
            index < self.tabCount && index >= 0
            else {
                return nil
        }

        if (self.contents[index] as UIViewController?) == nil {
            var viewController: UIViewController?

            if dataSource.responds(to: #selector(PagerDataSource.controllerForTabAtIndex(_: pager:))) {
                viewController = dataSource.controllerForTabAtIndex?(index, pager: self)
            } else if dataSource.responds(to: #selector(PagerDataSource.viewForTabAtIndex(_: pager:))) {
                // Adjust view's bounds to match the pageView's bounds
                if let view = dataSource.viewForTabAtIndex?(index, pager: self),
                   let pageView = self.view.viewWithTag(34) {
                    view.frame = pageView.bounds

                    viewController = UIViewController()
                    viewController?.view = view
                }
            } else {
                viewController = self.tabControllers[index]
            }

            if let vc = viewController {
                self.contents[index] = vc
                self.pageViewController.addChildViewController(vc)
            }
        }
        return self.contents[index]
    }

    // MARK: - Gestures
    @IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
        if let tabView = sender.view,
           let index = self.tabs.find({ $0 == tabView }) {
            if self.activeTabIndex != index {
                self.selectTabAtIndex(index)
            }
        }
    }

    // MARK: - Page DataSource
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index: Int = self.indexForViewController(viewController)
        index -= 1
        return self.viewControllerAtIndex(index)
    }

    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index: Int = self.indexForViewController(viewController)
        index += 1
        return self.viewControllerAtIndex(index)
    }

    // MARK: - Page Delegate
    open func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let viewController: UIViewController = self.pageViewController.viewControllers?.first {
            let index: Int = self.indexForViewController(viewController)
            self.selectTabAtIndex(index, swipe: true)
        }
    }

    @nonobjc func setActiveContentIndex(_ activeContentIndex: Int) {
        // Get the desired viewController
        var viewController: UIViewController? = self.viewControllerAtIndex(activeContentIndex)
        if viewController == nil {
            viewController = UIViewController()
            viewController?.view = UIView()
            viewController?.view.backgroundColor = UIColor.clear
        }

        guard let vc = viewController else {
            return
        }

        weak var wPageViewController: UIPageViewController? = self.pageViewController
        weak var wSelf: PagerController? = self

        if activeContentIndex == self.activeContentIndex {
            DispatchQueue.main.async {
                self.pageViewController.setViewControllers([vc], direction: .forward, animated: false, completion: {
                    (_: Bool) -> Void in
                    wSelf?.animatingToTab = false
                })
            }
        } else if !(activeContentIndex + 1 == self.activeContentIndex || activeContentIndex - 1 == self.activeContentIndex) {

            let direction: UIPageViewControllerNavigationDirection = (activeContentIndex < self.activeContentIndex) ? .reverse : .forward
            DispatchQueue.main.async {
                self.pageViewController.setViewControllers([vc], direction: direction, animated: true, completion: {
                    completed in

                    wSelf?.animatingToTab = false

                    if completed {
                        DispatchQueue.main.async(execute: {
                            () -> Void in
                            wPageViewController?.setViewControllers([vc], direction: direction, animated: false, completion: nil)
                        })
                    }
                })
            }
        } else {
            let direction: UIPageViewControllerNavigationDirection = (activeContentIndex < self.activeContentIndex) ? .reverse : .forward
            DispatchQueue.main.async {
                self.pageViewController.setViewControllers([vc], direction: direction, animated: true, completion: {
                    (_: Bool) -> Void in
                    wSelf?.animatingToTab = true
                })
            }
        }

        // Clean out of sight contents
        var index: Int = self.activeContentIndex - 1
        if index >= 0 && index != activeContentIndex && index != activeContentIndex - 1 {
            self.contents[index] = nil
        }
        index = self.activeContentIndex
        if index != activeContentIndex - 1 && index != activeContentIndex && index != activeContentIndex + 1 {
            self.contents[index] = nil
        }
        index = self.activeContentIndex + 1
        if index < self.contents.count && index != activeContentIndex && index != activeContentIndex + 1 {
            self.contents[index] = nil
        }
        self.activeContentIndex = activeContentIndex
    }

    // MARK: - UIScrollViewDelegate
    // MARK: Responding to Scrolling and Dragging
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let actualDelegate = self.actualDelegate {
            if actualDelegate.responds(to: #selector(UIScrollViewDelegate.scrollViewDidScroll(_:))) {
                actualDelegate.scrollViewDidScroll?(scrollView)
            }
        }

        guard let tabView = self.tabViewAtIndex(self.activeTabIndex),
              let tabsView = self.tabsView else {
            return
        }

        if !self.animatingToTab {

            // Get the related tab view position
            var frame: CGRect = tabView.frame
            let movedRatio: CGFloat = (scrollView.contentOffset.x / scrollView.frame.width) - 1
            frame.origin.x += movedRatio * frame.width

            if self.centerCurrentTab {

                frame.origin.x += (frame.size.width / 2)
                frame.origin.x -= tabsView.frame.width / 2
                frame.size.width = tabsView.frame.width

                if frame.origin.x < 0 {
                    frame.origin.x = 0
                }

                if (frame.origin.x + frame.size.width) > tabsView.contentSize.width {
                    frame.origin.x = (tabsView.contentSize.width - tabsView.frame.width)
                }
            } else {

                frame.origin.x -= self.tabOffset
                frame.size.width = tabsView.frame.width
            }

            tabsView.scrollRectToVisible(frame, animated: true)
        }

        var rect: CGRect = tabView.frame

        let updateIndicator = {
            (newX: CGFloat) -> Void in
            rect.origin.x = newX
            rect.origin.y = self.underlineStroke.frame.origin.y
            rect.size.height = self.underlineStroke.frame.size.height
            self.underlineStroke.frame = rect
        }

        var newX: CGFloat
        let width: CGFloat = self.view.frame.width
        let distance: CGFloat = tabView.frame.size.width

        if self.animation == PagerAnimation.during && !self.didTapOnTabView {
            if scrollView.panGestureRecognizer.translation(in: scrollView.superview).x > 0 {
                let mov: CGFloat = width - scrollView.contentOffset.x
                newX = rect.origin.x - ((distance * mov) / width)
            } else {
                let mov: CGFloat = scrollView.contentOffset.x - width
                newX = rect.origin.x + ((distance * mov) / width)
            }
            updateIndicator(newX)
        } else if self.animation == PagerAnimation.none {
            newX = tabView.frame.origin.x
            updateIndicator(newX)
        } else if self.animation == PagerAnimation.end || self.didTapOnTabView {
            newX = tabView.frame.origin.x
            UIView.animate(withDuration: 0.35, animations: {
                () -> Void in
                updateIndicator(newX)
            })
        }
    }

    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let actualDelegate = self.actualDelegate {
            if actualDelegate.responds(to: #selector(UIScrollViewDelegate.scrollViewWillBeginDragging(_:))) {
                actualDelegate.scrollViewWillBeginDragging?(scrollView)
            }
        }
    }

    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let actualDelegate = self.actualDelegate {
            if actualDelegate.responds(to: #selector(UIScrollViewDelegate.scrollViewWillEndDragging(_: withVelocity: targetContentOffset:))) {
                actualDelegate.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
            }
        }
    }

    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let actualDelegate = self.actualDelegate {
            if actualDelegate.responds(to: #selector(UIScrollViewDelegate.scrollViewDidEndDragging(_: willDecelerate:))) {
                actualDelegate.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
            }
        }
        self.didTapOnTabView = false
    }

    open func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if let actualDelegate = self.actualDelegate {
            if actualDelegate.responds(to: #selector(UIScrollViewDelegate.scrollViewShouldScrollToTop(_:))) {
                return actualDelegate.scrollViewShouldScrollToTop?(scrollView) ?? false
            }
        }
        return false
    }

    open func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        if let actualDelegate = self.actualDelegate {
            if actualDelegate.responds(to: #selector(UIScrollViewDelegate.scrollViewDidScrollToTop(_:))) {
                actualDelegate.scrollViewDidScrollToTop?(scrollView)
            }
        }
    }

    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if let actualDelegate = self.actualDelegate {
            if actualDelegate.responds(to: #selector(UIScrollViewDelegate.scrollViewWillBeginDecelerating(_:))) {
                actualDelegate.scrollViewWillBeginDecelerating?(scrollView)
            }
        }
    }

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let actualDelegate = self.actualDelegate {
            if actualDelegate.responds(to: #selector(UIScrollViewDelegate.scrollViewDidEndDecelerating(_:))) {
                actualDelegate.scrollViewDidEndDecelerating?(scrollView)
            }
        }
        self.didTapOnTabView = false
    }

    // MARK: Managing Zooming
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if let actualDelegate = self.actualDelegate {
            if actualDelegate.responds(to: #selector(UIScrollViewDelegate.viewForZooming(in:))) {
                return actualDelegate.viewForZooming?(in: scrollView)
            }
        }
        return nil
    }

    open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        if let actualDelegate = self.actualDelegate {
            if actualDelegate.responds(to: #selector(UIScrollViewDelegate.scrollViewWillBeginZooming(_:with:))) {
                actualDelegate.scrollViewWillBeginZooming?(scrollView, with: view)
            }
        }
    }

    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if let actualDelegate = self.actualDelegate {
            if actualDelegate.responds(to: #selector(UIScrollViewDelegate.scrollViewDidEndZooming(_:with:atScale:))) {
                actualDelegate.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
            }
        }
    }

    open func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if let actualDelegate = self.actualDelegate {
            if actualDelegate.responds(to: #selector(UIScrollViewDelegate.scrollViewDidZoom(_:))) {
                actualDelegate.scrollViewDidZoom?(scrollView)
            }
        }
    }

    // UIScrollViewDelegate, Responding to Scrolling Animations
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let actualDelegate = self.actualDelegate {
            if actualDelegate.responds(to: #selector(UIScrollViewDelegate.scrollViewDidEndScrollingAnimation(_:))) {
                actualDelegate.scrollViewDidEndScrollingAnimation?(scrollView)
            }
        }
        self.didTapOnTabView = false
    }
}

// MARK: - TabView
class TabView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
    }
}

// MARK: - Extensions
extension Array {
    func find(_ includedElement: (Element) -> Bool) -> Int? {
        for (idx, element) in self.enumerated() {
            if includedElement(element) {
                return idx
            }
        }
        return 0
    }
}
