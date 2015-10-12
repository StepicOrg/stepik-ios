//
//  RGPageViewController.swift
//  RGViewPager
//
//  Created by Ronny Gerasch on 08.11.14.
//  Copyright (c) 2014 Ronny Gerasch. All rights reserved.
//

import Foundation
import UIKit

enum RGTabbarStyle {
    case Solid
    case Blurred
}
enum RGTabStyle {
    case None
    case InactiveFaded
}
enum RGTabbarPosition {
    case Top
    case Bottom
    case Left
    case Right
}

class RGPageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIToolbarDelegate {
    // MARK: - Protocols
    weak var datasource: RGPageViewControllerDataSource?
    weak var delegate: RGPageViewControllerDelegate?
    var pageViewScrollDelegate: UIScrollViewDelegate?
    
    // MARK: - Variables
    var animatingToTab: Bool = false
    var needsSetup: Bool = true
    var needsLayoutSubviews = true
    // MARK: - Pager
    var pageCount: Int! = 0
    var currentPageIndex: Int = 0
    var pager: UIPageViewController!
    var pagerOrientation: UIPageViewControllerNavigationOrientation {
        get {
            return .Horizontal
        }
    }
    var pagerScrollView: UIScrollView!
    var pageViewControllers: NSMutableArray = NSMutableArray()
    // MARK: - Tabs
    var currentTabIndex: Int = 0
    var tabWidth: CGFloat = UIScreen.mainScreen().bounds.size.width / 3.0
    var tabbarWidth: CGFloat {
        get {
            return 100.0
        }
    }
    var tabbarHeight: CGFloat {
        get {
            return 38.0
        }
    }
    var tabIndicatorWidthOrHeight: CGFloat {
        get {
            return 2.0
        }
    }
    var tabIndicatorColor: UIColor {
        get {
            return UIColor.lightGrayColor()
        }
    }
    var tabMargin: CGFloat {
        get {
            return 0.0
        }
    }
    var tabStyle: RGTabStyle {
        get {
            return .None
        }
    }
    // MARK: - Tabbar
    var tabbarHidden: Bool {
        get {
            return false
        }
    }
    var tabbarStyle: RGTabbarStyle {
        get {
            return .Blurred
        }
    }
    var tabbarPosition: RGTabbarPosition {
        get {
            return .Top
        }
    }
    var tabbar: UIView!
    var barTintColor: UIColor? {
        get {
            return nil
        }
    }
    var tabScrollView: UICollectionView!
    
    // MARK: - Constructors
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // MARK: - ViewController life cycle
    override func loadView() {
        super.loadView()
        
        // init pager
        pager = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: pagerOrientation, options: nil)
        
        addChildViewController(pager)
        
        pagerScrollView = pager.view.subviews[0] as! UIScrollView
        pageViewScrollDelegate = pagerScrollView.delegate
        
        pagerScrollView.scrollsToTop = false
        pagerScrollView.delegate = self
        
        // init tabbar
        switch tabbarStyle {
        case .Blurred:
            tabbar = UIToolbar()
            
            if let bar = tabbar as? UIToolbar {
                bar.barTintColor = barTintColor
                bar.translucent = true
                bar.delegate = self
            }
        case .Solid:
            tabbar = UIView()
            
            tabbar.backgroundColor = barTintColor
        }
        
        tabbar.hidden = tabbarHidden
        
        // layout
        switch tabbarPosition {
        case .Top:
            layoutTabbarTop()
            break
        case .Bottom:
            layoutTabbarBottom()
            break
        case .Left:
            layoutTabbarLeft()
            break
        case .Right:
            layoutTabbarRight()
            break
        }
        
        tabScrollView.backgroundColor = UIColor.clearColor()
        tabScrollView.scrollsToTop = false
        tabScrollView.opaque = false
        tabScrollView.showsHorizontalScrollIndicator = false
        tabScrollView.showsVerticalScrollIndicator = false
        tabScrollView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "rgTabCell")
        
        tabbar.addSubview(tabScrollView)
        
        view.addSubview(pager.view)
        view.addSubview(tabbar)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if needsSetup {
            setupSelf()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Functions
    private func layoutTabbarTop() {
        tabbar.autoresizingMask = .FlexibleWidth
        pager.view.autoresizingMask = ([UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth])
        
        var barTop: CGFloat = 20
        
        // remove hairline image in navigation bar if attached to top
        if let navController = navigationController where !navController.navigationBar.hidden {
            barTop = 0//64
            //CHANGE WAS MADE HERE
            
            navController.navigationBar.hideHairline()
        }
        
        let tabbarFrame = CGRect(x: 0, y: barTop, width: view.bounds.size.width, height: tabbarHidden ? 0 : tabbarHeight)
        
        tabbar.frame = tabbarFrame
        
        let tabScrollerFrame = CGRect(x: 0, y: 0, width: tabbarFrame.size.width, height: tabbarFrame.size.height)
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.scrollDirection = .Horizontal
        
        tabScrollView = UICollectionView(frame: tabScrollerFrame, collectionViewLayout: flowLayout)
        
        tabScrollView.autoresizingMask = .FlexibleWidth
        
        let pagerFrame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
        
        pager.view.frame = pagerFrame
    }
    
    private func layoutTabbarBottom() {
        tabbar.autoresizingMask = .FlexibleWidth
        pager.view.autoresizingMask = ([UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth])
        
        let tabbarFrame = CGRect(x: 0, y: view.bounds.size.height - tabbarHeight, width: view.bounds.size.width, height: tabbarHidden ? 0 : tabbarHeight)
        
        tabbar.frame = tabbarFrame
        
        let tabScrollerFrame = CGRect(x: 0, y: 0, width: tabbarFrame.size.width, height: tabbarFrame.size.height)
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.scrollDirection = .Horizontal
        
        tabScrollView = UICollectionView(frame: tabScrollerFrame, collectionViewLayout: flowLayout)
        
        tabScrollView.autoresizingMask = .FlexibleWidth
        
        let pagerFrame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
        
        pager.view.frame = pagerFrame
    }
    
    private func layoutTabbarLeft() {
        tabbar.autoresizingMask = .FlexibleHeight
        pager.view.autoresizingMask = ([.FlexibleHeight, .FlexibleWidth])
        
        var barTop: CGFloat = 0
        
        // scroll tabbar under topbar if using solid style
        if tabbarStyle != .Solid {
            barTop = 20
            
            if let navController = navigationController where !navController.navigationBar.hidden {
                barTop = 64
            }
        }
        
        let tabbarFrame = CGRect(x: 0, y: barTop, width: tabbarHidden ? 0 : tabbarWidth, height: view.bounds.size.height - barTop)
        
        tabbar.frame = tabbarFrame
        
        let tabScrollerFrame = CGRect(x: 0, y: 0, width: tabbarFrame.size.width, height: tabbarFrame.size.height)
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.scrollDirection = .Vertical
        
        tabScrollView = UICollectionView(frame: tabScrollerFrame, collectionViewLayout: flowLayout)
        
        tabScrollView.autoresizingMask = .FlexibleHeight
        
        if tabbarStyle == .Solid {
            var scrollTop: CGFloat = 20
            
            if let navController = navigationController where !navController.navigationBar.hidden {
                scrollTop = 64
            }
            
            var edgeInsets: UIEdgeInsets = tabScrollView.contentInset
            
            edgeInsets.top = scrollTop
            edgeInsets.bottom = 0
            
            tabScrollView.contentInset = edgeInsets
            tabScrollView.scrollIndicatorInsets = edgeInsets
        }
        
        let pagerFrame = CGRect(x: tabbarHidden ? 0 : tabbarWidth, y: 0, width: view.bounds.size.width - (tabbarHidden ? 0 : tabbarWidth), height: view.bounds.size.height)
        
        pager.view.frame = pagerFrame
    }
    
    private func layoutTabbarRight() {
        tabbar.autoresizingMask = .FlexibleHeight
        pager.view.autoresizingMask = ([.FlexibleHeight, .FlexibleWidth])
        
        var barTop: CGFloat = 0
        
        // scroll tabbar under topbar if using solid style
        if tabbarStyle != .Solid {
            barTop = 20
            
            if let navController = self.navigationController where !navController.navigationBar.hidden {
                barTop = 64
            }
        }
        
        let tabbarFrame = CGRect(x: view.bounds.size.width - tabbarWidth, y: barTop, width: tabbarHidden ? 0 : tabbarWidth, height: view.bounds.size.height - barTop)
        
        tabbar.frame = tabbarFrame
        
        let tabScrollerFrame = CGRect(x: 0, y: 0, width: tabbarFrame.size.width, height: tabbarFrame.size.height)
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.scrollDirection = .Vertical
        
        tabScrollView = UICollectionView(frame: tabScrollerFrame, collectionViewLayout: flowLayout)
        
        tabScrollView.autoresizingMask = .FlexibleHeight
        
        if tabbarStyle == .Solid {
            var scrollTop: CGFloat = 20
            
            if let navController = navigationController where !navController.navigationBar.hidden {
                scrollTop = 64
            }
            
            var edgeInsets: UIEdgeInsets = tabScrollView.contentInset
            
            edgeInsets.top = scrollTop
            edgeInsets.bottom = 0
            
            tabScrollView.contentInset = edgeInsets
            tabScrollView.scrollIndicatorInsets = edgeInsets
        }
        
        let pagerFrame = CGRect(x: 0, y: 0, width: view.bounds.size.width - (tabbarHidden ? 0 : tabbarWidth), height: view.bounds.size.height)
        
        pager.view.frame = pagerFrame
    }
    
    private func setupSelf() {
        if let theSource = datasource {
            pageCount = theSource.numberOfPagesForViewController(self)
        }
        
        pageViewControllers.removeAllObjects()
        pageViewControllers = NSMutableArray(capacity: pageCount)
        
        for _ in 0 ..< pageCount {
            pageViewControllers.addObject(NSNull())
        }
        
        pager.dataSource = self
        pager.delegate = self
        tabScrollView.dataSource = self
        tabScrollView.delegate = self
        
        selectTabAtIndex(currentTabIndex, updatePage: true)
        
        needsSetup = false
    }
    
    private func tabViewAtIndex(index: Int) -> RGTabView? {
        if let tabViewContent: UIView = datasource?.tabViewForPageAtIndex(self, index: index) {
            var tabView: RGTabView
            
            switch tabbarPosition {
            case .Top, .Bottom:
                if let theWidth: CGFloat = delegate?.widthForTabAtIndex?(index) {
                    tabView = RGTabView(frame: CGRectMake(0.0, 0.0, theWidth, tabbarHeight), indicatorColor: tabIndicatorColor, indicatorHW: tabIndicatorWidthOrHeight, style: tabStyle, orientation: .Horizontal)
                } else {
                    tabView = RGTabView(frame: CGRectMake(0.0, 0.0, tabWidth, tabbarHeight), indicatorColor: tabIndicatorColor, indicatorHW: tabIndicatorWidthOrHeight, style: tabStyle, orientation: .Horizontal)
                }
                
                break
            case .Left:
                if let theHeight: CGFloat = delegate?.heightForTabAtIndex?(index) {
                    tabView = RGTabView(frame: CGRectMake(0.0, 0.0, tabbarWidth, theHeight), indicatorColor: tabIndicatorColor, indicatorHW: tabIndicatorWidthOrHeight, style: tabStyle, orientation: .VerticalLeft)
                } else {
                    tabView = RGTabView(frame: CGRectMake(0.0, 0.0, tabbarWidth, tabbarWidth), indicatorColor: tabIndicatorColor, indicatorHW: tabIndicatorWidthOrHeight, style: tabStyle, orientation: .VerticalLeft)
                }
                
                break
            case .Right:
                if let theHeight: CGFloat = delegate?.heightForTabAtIndex?(index) {
                    tabView = RGTabView(frame: CGRectMake(0.0, 0.0, tabbarWidth, theHeight), indicatorColor: tabIndicatorColor, indicatorHW: tabIndicatorWidthOrHeight, style: tabStyle, orientation: .VerticalRight)
                } else {
                    tabView = RGTabView(frame: CGRectMake(0.0, 0.0, tabbarWidth, tabbarWidth), indicatorColor: tabIndicatorColor, indicatorHW: tabIndicatorWidthOrHeight, style: tabStyle, orientation: .VerticalRight)
                }
                
                break
            }
            
            tabView.addSubview(tabViewContent)
            
            tabView.clipsToBounds = true
            
            tabViewContent.center = tabView.center
            
            return tabView
        }
        
        return nil
    }
    
    func selectTabAtIndex(index: Int, updatePage: Bool) {
        if index >= pageCount {
            return
        }
        
        animatingToTab = true
        
        updateTabIndex(index, animated: true)
        
        if updatePage {
            updatePager(index)
        } else {
            currentPageIndex = index
        }
        
        delegate?.didChangePageToIndex?(index)
    }
    
    private func updateTabIndex(index: Int, animated: Bool) {
        if let currentTabCell = tabScrollView.cellForItemAtIndexPath(NSIndexPath(forRow: currentTabIndex, inSection: 0)) {
            (currentTabCell.contentView.subviews.first as! RGTabView).selected = false
        }
        if let newTabCell = tabScrollView.cellForItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) {
            var newTabRect = newTabCell.frame
            
            switch tabbarPosition {
            case .Top, .Bottom:
                newTabRect.origin.x -= (index == 0 ? tabMargin : tabMargin / 2.0)
                newTabRect.size.width += tabMargin
            case .Left, .Right:
                newTabRect.origin.y -= tabMargin / 2.0
                newTabRect.size.height += tabMargin
            }
            
            let rect = tabScrollView.convertRect(newTabRect, toView: tabScrollView.superview)
            let newTabVisible = CGRectContainsRect(tabScrollView.frame, rect)
            
            if !newTabVisible {
                var scrollPosition: UICollectionViewScrollPosition = .None
                
                if index > currentTabIndex {
                    switch tabbarPosition {
                    case .Top, .Bottom:
                        scrollPosition = .Right
                    case .Left, .Right:
                        scrollPosition = .Bottom
                    }
                } else {
                    switch tabbarPosition {
                    case .Top, .Bottom:
                        scrollPosition = .Left
                    case .Left, .Right:
                        scrollPosition = .Top
                    }
                }
                
                tabScrollView.selectItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: animated, scrollPosition: scrollPosition)
                tabScrollView.scrollRectToVisible(newTabRect, animated: animated)
            }
            
            (newTabCell.contentView.subviews.first as! RGTabView).selected = true
        } else {
            let newTabCell = collectionView(tabScrollView, cellForItemAtIndexPath: NSIndexPath(forRow: index, inSection: 0))
            var newTabRect = newTabCell.frame
            
            switch tabbarPosition {
            case .Top, .Bottom:
                newTabRect.origin.x -= (index == 0 ? tabMargin : tabMargin / 2.0)
                newTabRect.size.width += tabMargin
            case .Left, .Right:
                newTabRect.origin.y -= tabMargin / 2.0
                newTabRect.size.height += tabMargin
            }
            
            let rect = tabScrollView.convertRect(newTabRect, toView: tabScrollView.superview)
            let newTabVisible = CGRectContainsRect(tabScrollView.frame, rect)
            
            if !newTabVisible {
                var scrollPosition: UICollectionViewScrollPosition = .None
                
                if index > currentTabIndex {
                    switch tabbarPosition {
                    case .Top, .Bottom:
                        scrollPosition = .Right
                    case .Left, .Right:
                        scrollPosition = .Bottom
                    }
                } else {
                    switch tabbarPosition {
                    case .Top, .Bottom:
                        scrollPosition = .Left
                    case .Left, .Right:
                        scrollPosition = .Top
                    }
                }
                
                tabScrollView.selectItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: animated, scrollPosition: scrollPosition)
                tabScrollView.scrollRectToVisible(newTabRect, animated: animated)
            }
            
            (newTabCell.contentView.subviews.first as! RGTabView).selected = true
        }
        
        currentTabIndex = index
    }
    
    private func updatePager(index: Int) {
        if let vc: UIViewController = viewControllerAtIndex(index) {
            weak var weakSelf: RGPageViewController? = self
            weak var weakPager: UIPageViewController? = pager
            
            if index == currentPageIndex {
                pager.setViewControllers([vc], direction: .Forward, animated: false, completion: { (Bool) -> Void in
                    weakSelf!.animatingToTab = false
                })
            } else if !(index + 1 == currentPageIndex || index - 1 == currentPageIndex) {
                pager.setViewControllers([vc], direction: index < currentPageIndex ? .Reverse : .Forward, animated: true, completion: { (Bool) -> Void in
                    weakSelf!.animatingToTab = false
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        weakPager!.setViewControllers([vc], direction: index < weakSelf!.currentPageIndex ? .Reverse : .Forward, animated: false, completion: nil)
                    })
                })
            } else {
                pager.setViewControllers([vc], direction: index < currentPageIndex ? .Reverse : .Forward, animated: true, completion: { (Bool) -> Void in
                    weakSelf!.animatingToTab = false
                })
            }
            
            currentPageIndex = index
        }
    }
    
    private func indexForViewController(vc: UIViewController) -> (Int) {
        return pageViewControllers.indexOfObject(vc)
    }
    
    func reloadData() {
        if let theSource = datasource {
            pageCount = theSource.numberOfPagesForViewController(self)
        }
        
        pageViewControllers.removeAllObjects()
        pageViewControllers = NSMutableArray(capacity: pageCount)
        
        for _ in 0 ..< pageCount {
            pageViewControllers.addObject(NSNull())
        }
        
        tabScrollView.reloadData()
        
        selectTabAtIndex(currentTabIndex, updatePage: true)
    }
    
    // MARK: - UIToolbarDelegate
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        var position: UIBarPosition = UIBarPosition.Top
        
        switch tabbarPosition {
        case .Top:
            position = UIBarPosition.Top
        case .Bottom:
            position = UIBarPosition.Bottom
        case .Left, .Right:
            position = UIBarPosition.Any
        }
        
        return position
    }
    
    // MARK: - PageViewController Data Source
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index: Int = indexForViewController(viewController)
        
        if index == 0 {
            return nil
        }
        
        index--
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index: Int = indexForViewController(viewController)
        
        if index == pageCount - 1 {
            return nil
        }
        
        index++
        
        return viewControllerAtIndex(index)
    }
    
    private func viewControllerAtIndex(index: Int) -> UIViewController? {
        if index >= pageCount {
            return nil
        }
        
        if pageViewControllers.objectAtIndex(index).isEqual(NSNull()), let vc: UIViewController = datasource?.viewControllerForPageAtIndex(self, index: index) {
            let view: UIView = vc.view.subviews[0]
            
            if view is UIScrollView {
                let scrollView = (view as! UIScrollView)
                var edgeInsets: UIEdgeInsets = scrollView.contentInset
                
                if tabbarPosition == .Top {
                    edgeInsets.top = tabbar.frame.origin.y + tabbarHeight
                } else if tabbarPosition == .Bottom {
                    edgeInsets.top = tabbar.frame.origin.y
                    edgeInsets.bottom = tabbarHeight
                } else {
                    edgeInsets.top = tabbar.frame.origin.y
                    edgeInsets.bottom = 0
                }
                
                scrollView.contentInset = edgeInsets
                scrollView.scrollIndicatorInsets = edgeInsets
            }
            
            pageViewControllers.replaceObjectAtIndex(index, withObject: vc)
        }
        
        return pageViewControllers.objectAtIndex(index) as? UIViewController
    }
    
    // MARK: - PageViewController Delegate
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished && completed, let vc: UIViewController = pager.viewControllers?.first as UIViewController? {
            let index: Int = indexForViewController(vc)
            
            selectTabAtIndex(index, updatePage: false)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageCount
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("rgTabCell", forIndexPath: indexPath)
        
        cell.tag = indexPath.row
        
        if let tabView = tabViewAtIndex(indexPath.row) {
            for view in cell.contentView.subviews {
                view.removeFromSuperview()
            }
            
            if indexPath.row == currentTabIndex {
                tabView.selected = true
            } else {
                tabView.selected = false
            }
            
            cell.contentView.addSubview(tabView)
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if currentTabIndex != indexPath.row {
            selectTabAtIndex(indexPath.row, updatePage: true)
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        switch tabbarPosition {
        case .Top, .Bottom:
            if let theWidth: CGFloat = delegate?.widthForTabAtIndex?(indexPath.row) {
                return CGSize(width: theWidth, height: tabbarHeight)
            } else {
                return CGSize(width: tabWidth, height: tabbarHeight)
            }
        case .Left, .Right:
            if let theHeight: CGFloat = delegate?.heightForTabAtIndex?(indexPath.row) {
                return CGSize(width: tabbarWidth, height: theHeight)
            } else {
                return CGSize(width: tabbarWidth, height: tabbarWidth)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return tabMargin
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return tabMargin
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        switch tabbarPosition {
        case .Top, .Bottom:
            return UIEdgeInsets(top: 0, left: tabMargin / 2, bottom: 0, right: tabMargin / 2)
        case .Left, .Right:
            return UIEdgeInsets(top: tabMargin / 2, left: 0, bottom: tabMargin / 2, right: 0)
        }
    }
    
    // MARK: - UIScrollView Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        if scrollView == tabScrollView {
            return false
        }
        
        if let shouldScroll = pageViewScrollDelegate?.scrollViewShouldScrollToTop?(scrollView) {
            return shouldScroll
        }
        
        return false
    }
    
    func scrollViewDidScrollToTop(scrollView: UIScrollView) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewDidScrollToTop?(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewWillBeginZooming?(scrollView, withView: view)
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewDidZoom?(scrollView)
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewDidEndZooming?(scrollView, withView: view, atScale: scale)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        if scrollView == tabScrollView {
            return nil
        }
        
        if let view: UIView = pageViewScrollDelegate?.viewForZoomingInScrollView?(scrollView) {
            return view
        }
        
        return nil
    }
}

// MARK: - RGTabView
private class RGTabView: UIView {
    enum RGTabOrientation {
        case Horizontal
        case VerticalLeft
        case VerticalRight
    }
    
    // variables
    var selected: Bool = false {
        didSet {
            if subviews[0] is RGTabBarItem {
                (subviews[0] as! RGTabBarItem).selected = selected
            } else {
                if style == .InactiveFaded {
                    if selected {
                        alpha = 1.0
                    } else {
                        alpha = 0.566
                    }
                }
                
                setNeedsDisplay()
            }
        }
    }
    var indicatorHW: CGFloat = 2.0
    var indicatorColor: UIColor = UIColor.lightGrayColor()
    var orientation: RGTabOrientation = .Horizontal
    var style: RGTabStyle = .None
    
    init(frame: CGRect, indicatorColor: UIColor, indicatorHW: CGFloat, style: RGTabStyle, orientation: RGTabOrientation) {
        super.init(frame: frame)
        
        self.indicatorColor = indicatorColor
        self.orientation = orientation
        self.indicatorHW = indicatorHW
        self.style = style
        
        initSelf()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initSelf()
    }
    
    func initSelf() {
        backgroundColor = UIColor.clearColor()
        
        if style == .InactiveFaded {
            alpha = 0.566
        }
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if selected {
            if !(subviews[0] is RGTabBarItem) {
                let bezierPath: UIBezierPath = UIBezierPath()
                
                switch orientation {
                case .Horizontal:
                    bezierPath.moveToPoint(CGPointMake(0.0, CGRectGetHeight(rect) - indicatorHW / 2.0))
                    bezierPath.addLineToPoint(CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect) - indicatorHW / 2.0))
                    bezierPath.lineWidth = indicatorHW
                case .VerticalLeft:
                    bezierPath.moveToPoint(CGPointMake(indicatorHW / 2.0, 0.0))
                    bezierPath.addLineToPoint(CGPointMake(indicatorHW / 2.0, CGRectGetHeight(rect)))
                    bezierPath.lineWidth = indicatorHW
                case .VerticalRight:
                    bezierPath.moveToPoint(CGPointMake(CGRectGetWidth(rect) - (indicatorHW / 2.0), 0.0))
                    bezierPath.addLineToPoint(CGPointMake(CGRectGetWidth(rect) - (indicatorHW / 2.0), CGRectGetHeight(rect)))
                    bezierPath.lineWidth = indicatorHW
                }
                
                indicatorColor.setStroke()
                
                bezierPath.stroke()
            }
        }
    }
}

// MARK: - RGTabBarItem
class RGTabBarItem: UIView {
    var selected: Bool = false {
        didSet {
            setSelectedState()
        }
    }
    var text: String?
    var image: UIImage?
    var textLabel: UILabel?
    var imageView: UIImageView?
    var normalColor: UIColor? = UIColor.grayColor()
    
    init(frame: CGRect, text: String?, image: UIImage?, color: UIColor?) {
        super.init(frame: frame)
        
        self.text = text
        self.image = image?.imageWithRenderingMode(.AlwaysTemplate)
        
        if color != nil {
            normalColor = color
        }
        
        initSelf()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSelf()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initSelf()
    }
    
    func initSelf() {
        backgroundColor = UIColor.clearColor()
        
        if let img = image {
            imageView = UIImageView(image: img)
            
            addSubview(imageView!)
            
            imageView!.tintColor = normalColor
            imageView!.center.x = center.x
            imageView!.center.y = center.y - 5.0
        }
        
        if let txt = text {
            textLabel = UILabel()
            
            textLabel!.numberOfLines = 1
            textLabel!.text = txt
            textLabel!.textAlignment = NSTextAlignment.Center
            textLabel!.textColor = normalColor
            textLabel!.font = UIFont(name: "HelveticaNeue", size: 10)
            
            textLabel!.sizeToFit()
            
            textLabel!.frame = CGRectMake(0.0, frame.size.height - textLabel!.frame.size.height - 3.0, frame.size.width, textLabel!.frame.size.height)
            
            addSubview(textLabel!)
        }
    }
    
    func setSelectedState() {
        if selected {
            textLabel?.textColor = tintColor
            imageView?.tintColor = tintColor
        } else {
            textLabel?.textColor = normalColor
            imageView?.tintColor = normalColor
        }
    }
}

// MARK: - UINavigationBar hide Hairline
extension UINavigationBar {
    func hideHairline() {
        if let hairlineView: UIImageView = findHairlineImageView(containedIn: self) {
            hairlineView.hidden = true
        }
    }
    
    func showHairline() {
        if let hairlineView: UIImageView = findHairlineImageView(containedIn: self) {
            hairlineView.hidden = false
        }
    }
    
    func findHairlineImageView(containedIn view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1.0 {
            return view as? UIImageView
        }
        
        for subview in view.subviews {
            if let imageView: UIImageView = findHairlineImageView(containedIn: subview ) {
                return imageView
            }
        }
        
        return nil
    }
}

// MARK: - RGPageViewController Data Source
@objc protocol RGPageViewControllerDataSource {
    /// Asks dataSource how many pages will there be.
    ///
    /// - parameter pageViewController: the RGPageViewController instance that's subject to
    ///
    /// - returns: the total number of pages
    func numberOfPagesForViewController(pageViewController: RGPageViewController) -> Int
    
    /// Asks dataSource to give a view to display as a tab item.
    ///
    /// - parameter pageViewController: the RGPageViewController instance that's subject to
    /// - parameter index: the index of the tab whose view is asked
    ///
    /// - returns: a UIView instance that will be shown as tab at the given index
    func tabViewForPageAtIndex(pageViewController: RGPageViewController, index: Int) -> UIView
    
    /// The content for any tab. Return a UIViewController instance and RGPageViewController will use its view to show as content.
    ///
    /// - parameter pageViewController: the RGPageViewController instance that's subject to
    /// - parameter index: the index of the content whose view is asked
    ///
    /// - returns: a UIViewController instance whose view will be shown as content
    func viewControllerForPageAtIndex(pageViewController: RGPageViewController, index: Int) -> UIViewController?
}

// MARK: - RGPageViewController Delegate
@objc protocol RGPageViewControllerDelegate {
    /// Delegate objects can implement this method if want to be informed when a page changed.
    ///
    /// - parameter index: the index of the active page
    optional func willChangePageToIndex(index: Int, fromIndex from: Int)
    
    /// Delegate objects can implement this method if want to be informed when a page changed.
    ///
    /// - parameter index: the index of the active page
    optional func didChangePageToIndex(index: Int)
    
    /// Delegate objects can implement this method if tabs use dynamic width.
    ///
    /// - parameter index: the index of the tab
    /// - returns: the width for the tab at the given index
    optional func widthForTabAtIndex(index: Int) -> CGFloat
    
    /// Delegate objects can implement this method if tabs use dynamic height.
    ///
    /// - parameter index: the index of the tab
    /// - returns: the height for the tab at the given index
    optional func heightForTabAtIndex(index: Int) -> CGFloat
}
