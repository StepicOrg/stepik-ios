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
    case solid
    case blurred
}
enum RGTabStyle {
    case none
    case inactiveFaded
}
enum RGTabbarPosition {
    case top
    case bottom
    case left
    case right
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
            return .horizontal
        }
    }
    var pagerScrollView: UIScrollView!
    var pageViewControllers: NSMutableArray = NSMutableArray()
    // MARK: - Tabs
    var currentTabIndex: Int = 0
    var tabWidth: CGFloat = UIScreen.main.bounds.size.width / 3.0
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
            return UIColor.lightGray
        }
    }
    var tabMargin: CGFloat {
        get {
            return 0.0
        }
    }
    var tabStyle: RGTabStyle {
        get {
            return .none
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
            return .blurred
        }
    }
    var tabbarPosition: RGTabbarPosition {
        get {
            return .top
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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // MARK: - ViewController life cycle
    override func loadView() {
        super.loadView()
        
        // init pager
        pager = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: pagerOrientation, options: nil)
        
        addChildViewController(pager)
        
        pagerScrollView = pager.view.subviews[0] as! UIScrollView
        pageViewScrollDelegate = pagerScrollView.delegate
        
        pagerScrollView.scrollsToTop = false
        pagerScrollView.delegate = self
        
        // init tabbar
        switch tabbarStyle {
        case .blurred:
            tabbar = UIToolbar()
            
            if let bar = tabbar as? UIToolbar {
                bar.barTintColor = barTintColor
                bar.isTranslucent = true
                bar.delegate = self
            }
        case .solid:
            tabbar = UIView()
            
            tabbar.backgroundColor = barTintColor
        }
        
        tabbar.isHidden = tabbarHidden
        
        // layout
        switch tabbarPosition {
        case .top:
            layoutTabbarTop()
            break
        case .bottom:
            layoutTabbarBottom()
            break
        case .left:
            layoutTabbarLeft()
            break
        case .right:
            layoutTabbarRight()
            break
        }
        
        tabScrollView.backgroundColor = UIColor.clear
        tabScrollView.scrollsToTop = false
        tabScrollView.isOpaque = false
        tabScrollView.showsHorizontalScrollIndicator = false
        tabScrollView.showsVerticalScrollIndicator = false
        tabScrollView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "rgTabCell")
        
        tabbar.addSubview(tabScrollView)
        
        view.addSubview(pager.view)
        view.addSubview(tabbar)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if needsSetup {
            setupSelf()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Functions
    fileprivate func layoutTabbarTop() {
        tabbar.autoresizingMask = .flexibleWidth
        pager.view.autoresizingMask = ([UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth])
        
        var barTop: CGFloat = 20
        
        // remove hairline image in navigation bar if attached to top
        if let navController = navigationController , !navController.navigationBar.isHidden {
            barTop = 0//64
            //CHANGE WAS MADE HERE
            
            navController.navigationBar.hideHairline()
        }
        
        let tabbarFrame = CGRect(x: 0, y: barTop, width: view.bounds.size.width, height: tabbarHidden ? 0 : tabbarHeight)
        
        tabbar.frame = tabbarFrame
        
        let tabScrollerFrame = CGRect(x: 0, y: 0, width: tabbarFrame.size.width, height: tabbarFrame.size.height)
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.scrollDirection = .horizontal
        
        tabScrollView = UICollectionView(frame: tabScrollerFrame, collectionViewLayout: flowLayout)
        
        tabScrollView.autoresizingMask = .flexibleWidth
        
        let pagerFrame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
        
        pager.view.frame = pagerFrame
    }
    
    fileprivate func layoutTabbarBottom() {
        tabbar.autoresizingMask = .flexibleWidth
        pager.view.autoresizingMask = ([UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth])
        
        let tabbarFrame = CGRect(x: 0, y: view.bounds.size.height - tabbarHeight, width: view.bounds.size.width, height: tabbarHidden ? 0 : tabbarHeight)
        
        tabbar.frame = tabbarFrame
        
        let tabScrollerFrame = CGRect(x: 0, y: 0, width: tabbarFrame.size.width, height: tabbarFrame.size.height)
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.scrollDirection = .horizontal
        
        tabScrollView = UICollectionView(frame: tabScrollerFrame, collectionViewLayout: flowLayout)
        
        tabScrollView.autoresizingMask = .flexibleWidth
        
        let pagerFrame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
        
        pager.view.frame = pagerFrame
    }
    
    fileprivate func layoutTabbarLeft() {
        tabbar.autoresizingMask = .flexibleHeight
        pager.view.autoresizingMask = ([.flexibleHeight, .flexibleWidth])
        
        var barTop: CGFloat = 0
        
        // scroll tabbar under topbar if using solid style
        if tabbarStyle != .solid {
            barTop = 20
            
            if let navController = navigationController , !navController.navigationBar.isHidden {
                barTop = 64
            }
        }
        
        let tabbarFrame = CGRect(x: 0, y: barTop, width: tabbarHidden ? 0 : tabbarWidth, height: view.bounds.size.height - barTop)
        
        tabbar.frame = tabbarFrame
        
        let tabScrollerFrame = CGRect(x: 0, y: 0, width: tabbarFrame.size.width, height: tabbarFrame.size.height)
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.scrollDirection = .vertical
        
        tabScrollView = UICollectionView(frame: tabScrollerFrame, collectionViewLayout: flowLayout)
        
        tabScrollView.autoresizingMask = .flexibleHeight
        
        if tabbarStyle == .solid {
            var scrollTop: CGFloat = 20
            
            if let navController = navigationController , !navController.navigationBar.isHidden {
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
    
    fileprivate func layoutTabbarRight() {
        tabbar.autoresizingMask = .flexibleHeight
        pager.view.autoresizingMask = ([.flexibleHeight, .flexibleWidth])
        
        var barTop: CGFloat = 0
        
        // scroll tabbar under topbar if using solid style
        if tabbarStyle != .solid {
            barTop = 20
            
            if let navController = self.navigationController , !navController.navigationBar.isHidden {
                barTop = 64
            }
        }
        
        let tabbarFrame = CGRect(x: view.bounds.size.width - tabbarWidth, y: barTop, width: tabbarHidden ? 0 : tabbarWidth, height: view.bounds.size.height - barTop)
        
        tabbar.frame = tabbarFrame
        
        let tabScrollerFrame = CGRect(x: 0, y: 0, width: tabbarFrame.size.width, height: tabbarFrame.size.height)
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.scrollDirection = .vertical
        
        tabScrollView = UICollectionView(frame: tabScrollerFrame, collectionViewLayout: flowLayout)
        
        tabScrollView.autoresizingMask = .flexibleHeight
        
        if tabbarStyle == .solid {
            var scrollTop: CGFloat = 20
            
            if let navController = navigationController , !navController.navigationBar.isHidden {
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
    
    fileprivate func setupSelf() {
        if let theSource = datasource {
            pageCount = theSource.numberOfPagesForViewController(self)
        }
        
        pageViewControllers.removeAllObjects()
        pageViewControllers = NSMutableArray(capacity: pageCount)
        
        for _ in 0 ..< pageCount {
            pageViewControllers.add(NSNull())
        }
        
        pager.dataSource = self
        pager.delegate = self
        tabScrollView.dataSource = self
        tabScrollView.delegate = self
        
        selectTabAtIndex(currentTabIndex, updatePage: true)
        
        needsSetup = false
    }
    
    fileprivate func tabViewAtIndex(_ index: Int) -> RGTabView? {
        if let tabViewContent: UIView = datasource?.tabViewForPageAtIndex(self, index: index) {
            var tabView: RGTabView
            
            switch tabbarPosition {
            case .top, .bottom:
                if let theWidth: CGFloat = delegate?.widthForTabAtIndex?(index) {
                    tabView = RGTabView(frame: CGRect(x: 0.0, y: 0.0, width: theWidth, height: tabbarHeight), indicatorColor: tabIndicatorColor, indicatorHW: tabIndicatorWidthOrHeight, style: tabStyle, orientation: .horizontal)
                } else {
                    tabView = RGTabView(frame: CGRect(x: 0.0, y: 0.0, width: tabWidth, height: tabbarHeight), indicatorColor: tabIndicatorColor, indicatorHW: tabIndicatorWidthOrHeight, style: tabStyle, orientation: .horizontal)
                }
                
                break
            case .left:
                if let theHeight: CGFloat = delegate?.heightForTabAtIndex?(index) {
                    tabView = RGTabView(frame: CGRect(x: 0.0, y: 0.0, width: tabbarWidth, height: theHeight), indicatorColor: tabIndicatorColor, indicatorHW: tabIndicatorWidthOrHeight, style: tabStyle, orientation: .verticalLeft)
                } else {
                    tabView = RGTabView(frame: CGRect(x: 0.0, y: 0.0, width: tabbarWidth, height: tabbarWidth), indicatorColor: tabIndicatorColor, indicatorHW: tabIndicatorWidthOrHeight, style: tabStyle, orientation: .verticalLeft)
                }
                
                break
            case .right:
                if let theHeight: CGFloat = delegate?.heightForTabAtIndex?(index) {
                    tabView = RGTabView(frame: CGRect(x: 0.0, y: 0.0, width: tabbarWidth, height: theHeight), indicatorColor: tabIndicatorColor, indicatorHW: tabIndicatorWidthOrHeight, style: tabStyle, orientation: .verticalRight)
                } else {
                    tabView = RGTabView(frame: CGRect(x: 0.0, y: 0.0, width: tabbarWidth, height: tabbarWidth), indicatorColor: tabIndicatorColor, indicatorHW: tabIndicatorWidthOrHeight, style: tabStyle, orientation: .verticalRight)
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
    
    func selectTabAtIndex(_ index: Int, updatePage: Bool) {
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
    
    fileprivate func updateTabIndex(_ index: Int, animated: Bool) {
        if let currentTabCell = tabScrollView.cellForItem(at: IndexPath(row: currentTabIndex, section: 0)) {
            (currentTabCell.contentView.subviews.first as! RGTabView).selected = false
        }
        if let newTabCell = tabScrollView.cellForItem(at: IndexPath(row: index, section: 0)) {
            var newTabRect = newTabCell.frame
            
            switch tabbarPosition {
            case .top, .bottom:
                newTabRect.origin.x -= (index == 0 ? tabMargin : tabMargin / 2.0)
                newTabRect.size.width += tabMargin
            case .left, .right:
                newTabRect.origin.y -= tabMargin / 2.0
                newTabRect.size.height += tabMargin
            }
            
            let rect = tabScrollView.convert(newTabRect, to: tabScrollView.superview)
            let newTabVisible = tabScrollView.frame.contains(rect)
            
            if !newTabVisible {
                var scrollPosition: UICollectionViewScrollPosition = UICollectionViewScrollPosition()
                
                if index > currentTabIndex {
                    switch tabbarPosition {
                    case .top, .bottom:
                        scrollPosition = .right
                    case .left, .right:
                        scrollPosition = .bottom
                    }
                } else {
                    switch tabbarPosition {
                    case .top, .bottom:
                        scrollPosition = .left
                    case .left, .right:
                        scrollPosition = .top
                    }
                }
                
                tabScrollView.selectItem(at: IndexPath(row: index, section: 0), animated: animated, scrollPosition: scrollPosition)
                tabScrollView.scrollRectToVisible(newTabRect, animated: animated)
            }
            
            (newTabCell.contentView.subviews.first as! RGTabView).selected = true
        } else {
            let newTabCell = collectionView(tabScrollView, cellForItemAt: IndexPath(row: index, section: 0))
            var newTabRect = newTabCell.frame
            
            switch tabbarPosition {
            case .top, .bottom:
                newTabRect.origin.x -= (index == 0 ? tabMargin : tabMargin / 2.0)
                newTabRect.size.width += tabMargin
            case .left, .right:
                newTabRect.origin.y -= tabMargin / 2.0
                newTabRect.size.height += tabMargin
            }
            
            let rect = tabScrollView.convert(newTabRect, to: tabScrollView.superview)
            let newTabVisible = tabScrollView.frame.contains(rect)
            
            if !newTabVisible {
                var scrollPosition: UICollectionViewScrollPosition = UICollectionViewScrollPosition()
                
                if index > currentTabIndex {
                    switch tabbarPosition {
                    case .top, .bottom:
                        scrollPosition = .right
                    case .left, .right:
                        scrollPosition = .bottom
                    }
                } else {
                    switch tabbarPosition {
                    case .top, .bottom:
                        scrollPosition = .left
                    case .left, .right:
                        scrollPosition = .top
                    }
                }
                
                tabScrollView.selectItem(at: IndexPath(row: index, section: 0), animated: animated, scrollPosition: scrollPosition)
                tabScrollView.scrollRectToVisible(newTabRect, animated: animated)
            }
            
            (newTabCell.contentView.subviews.first as! RGTabView).selected = true
        }
        
        currentTabIndex = index
    }
    
    fileprivate func updatePager(_ index: Int) {
        if let vc: UIViewController = viewControllerAtIndex(index) {
            weak var weakSelf: RGPageViewController? = self
            weak var weakPager: UIPageViewController? = pager
            
            if index == currentPageIndex {
                pager.setViewControllers([vc], direction: .forward, animated: false, completion: { (Bool) -> Void in
                    weakSelf!.animatingToTab = false
                })
            } else if !(index + 1 == currentPageIndex || index - 1 == currentPageIndex) {
                pager.setViewControllers([vc], direction: index < currentPageIndex ? .reverse : .forward, animated: true, completion: { (Bool) -> Void in
                    weakSelf!.animatingToTab = false
                    
                    DispatchQueue.main.async(execute: {
                        weakPager!.setViewControllers([vc], direction: index < weakSelf!.currentPageIndex ? .reverse : .forward, animated: false, completion: nil)
                    })
                })
            } else {
                pager.setViewControllers([vc], direction: index < currentPageIndex ? .reverse : .forward, animated: true, completion: { (Bool) -> Void in
                    weakSelf!.animatingToTab = false
                })
            }
            
            currentPageIndex = index
        }
    }
    
    fileprivate func indexForViewController(_ vc: UIViewController) -> (Int) {
        return pageViewControllers.index(of: vc)
    }
    
    func reloadData() {
        if let theSource = datasource {
            pageCount = theSource.numberOfPagesForViewController(self)
        }
        
        pageViewControllers.removeAllObjects()
        pageViewControllers = NSMutableArray(capacity: pageCount)
        
        for _ in 0 ..< pageCount {
            pageViewControllers.add(NSNull())
        }
        
        tabScrollView.reloadData()
        
        selectTabAtIndex(currentTabIndex, updatePage: true)
    }
    
    // MARK: - UIToolbarDelegate
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        var position: UIBarPosition = UIBarPosition.top
        
        switch tabbarPosition {
        case .top:
            position = UIBarPosition.top
        case .bottom:
            position = UIBarPosition.bottom
        case .left, .right:
            position = UIBarPosition.any
        }
        
        return position
    }
    
    // MARK: - PageViewController Data Source
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index: Int = indexForViewController(viewController)
        
        if index <= 0 {
            return nil
        }
        
        index -= 1
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index: Int = indexForViewController(viewController)
        
        if index >= pageCount - 1 {
            return nil
        }
        
        index += 1
        
        return viewControllerAtIndex(index)
    }
    
    fileprivate func viewControllerAtIndex(_ index: Int) -> UIViewController? {
        if index >= pageCount {
            return nil
        }
        
        if (pageViewControllers.object(at: index) as AnyObject).isEqual(NSNull()), let vc: UIViewController = datasource?.viewControllerForPageAtIndex(self, index: index) {
            let view: UIView = vc.view.subviews[0]
            
            if view is UIScrollView {
                let scrollView = (view as! UIScrollView)
                var edgeInsets: UIEdgeInsets = scrollView.contentInset
                
                if tabbarPosition == .top {
                    edgeInsets.top = tabbar.frame.origin.y + tabbarHeight
                } else if tabbarPosition == .bottom {
                    edgeInsets.top = tabbar.frame.origin.y
                    edgeInsets.bottom = tabbarHeight
                } else {
                    edgeInsets.top = tabbar.frame.origin.y
                    edgeInsets.bottom = 0
                }
                
                scrollView.contentInset = edgeInsets
                scrollView.scrollIndicatorInsets = edgeInsets
            }
            
            pageViewControllers.replaceObject(at: index, with: vc)
        }
        
        return pageViewControllers.object(at: index) as? UIViewController
    }
    
    // MARK: - PageViewController Delegate
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished && completed, let vc: UIViewController = pager.viewControllers?.first as UIViewController? {
            let index: Int = indexForViewController(vc)
            
            selectTabAtIndex(index, updatePage: false)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rgTabCell", for: indexPath)
        
        cell.tag = (indexPath as NSIndexPath).row
        
        if let tabView = tabViewAtIndex((indexPath as NSIndexPath).row) {
            for view in cell.contentView.subviews {
                view.removeFromSuperview()
            }
            
            if (indexPath as NSIndexPath).row == currentTabIndex {
                tabView.selected = true
            } else {
                tabView.selected = false
            }
            
            cell.contentView.addSubview(tabView)
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentTabIndex != (indexPath as NSIndexPath).row {
            selectTabAtIndex((indexPath as NSIndexPath).row, updatePage: true)
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch tabbarPosition {
        case .top, .bottom:
            if let theWidth: CGFloat = delegate?.widthForTabAtIndex?((indexPath as NSIndexPath).row) {
                return CGSize(width: theWidth, height: tabbarHeight)
            } else {
                return CGSize(width: tabWidth, height: tabbarHeight)
            }
        case .left, .right:
            if let theHeight: CGFloat = delegate?.heightForTabAtIndex?((indexPath as NSIndexPath).row) {
                return CGSize(width: tabbarWidth, height: theHeight)
            } else {
                return CGSize(width: tabbarWidth, height: tabbarWidth)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return tabMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return tabMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch tabbarPosition {
        case .top, .bottom:
            return UIEdgeInsets(top: 0, left: tabMargin / 2, bottom: 0, right: tabMargin / 2)
        case .left, .right:
            return UIEdgeInsets(top: tabMargin / 2, left: 0, bottom: tabMargin / 2, right: 0)
        }
    }
    
    // MARK: - UIScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if scrollView == tabScrollView {
            return false
        }
        
        if let shouldScroll = pageViewScrollDelegate?.scrollViewShouldScrollToTop?(scrollView) {
            return shouldScroll
        }
        
        return false
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewDidScrollToTop?(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewDidZoom?(scrollView)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scrollView == tabScrollView {
            return
        }
        
        pageViewScrollDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView == tabScrollView {
            return nil
        }
        
        if let view: UIView = pageViewScrollDelegate?.viewForZooming?(in: scrollView) {
            return view
        }
        
        return nil
    }
}

// MARK: - RGTabView
private class RGTabView: UIView {
    enum RGTabOrientation {
        case horizontal
        case verticalLeft
        case verticalRight
    }
    
    // variables
    var selected: Bool = false {
        didSet {
            if subviews[0] is RGTabBarItem {
                (subviews[0] as! RGTabBarItem).selected = selected
            } else {
                if style == .inactiveFaded {
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
    var indicatorColor: UIColor = UIColor.lightGray
    var orientation: RGTabOrientation = .horizontal
    var style: RGTabStyle = .none
    
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
        backgroundColor = UIColor.clear
        
        if style == .inactiveFaded {
            alpha = 0.566
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if selected {
            if !(subviews[0] is RGTabBarItem) {
                let bezierPath: UIBezierPath = UIBezierPath()
                
                switch orientation {
                case .horizontal:
                    bezierPath.move(to: CGPoint(x: 0.0, y: rect.height - indicatorHW / 2.0))
                    bezierPath.addLine(to: CGPoint(x: rect.width, y: rect.height - indicatorHW / 2.0))
                    bezierPath.lineWidth = indicatorHW
                case .verticalLeft:
                    bezierPath.move(to: CGPoint(x: indicatorHW / 2.0, y: 0.0))
                    bezierPath.addLine(to: CGPoint(x: indicatorHW / 2.0, y: rect.height))
                    bezierPath.lineWidth = indicatorHW
                case .verticalRight:
                    bezierPath.move(to: CGPoint(x: rect.width - (indicatorHW / 2.0), y: 0.0))
                    bezierPath.addLine(to: CGPoint(x: rect.width - (indicatorHW / 2.0), y: rect.height))
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
    var normalColor: UIColor? = UIColor.gray
    
    init(frame: CGRect, text: String?, image: UIImage?, color: UIColor?) {
        super.init(frame: frame)
        
        self.text = text
        self.image = image?.withRenderingMode(.alwaysTemplate)
        
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
        backgroundColor = UIColor.clear
        
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
            textLabel!.textAlignment = NSTextAlignment.center
            textLabel!.textColor = normalColor
            textLabel!.font = UIFont(name: "HelveticaNeue", size: 10)
            
            textLabel!.sizeToFit()
            
            textLabel!.frame = CGRect(x: 0.0, y: frame.size.height - textLabel!.frame.size.height - 3.0, width: frame.size.width, height: textLabel!.frame.size.height)
            
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
            hairlineView.isHidden = true
        }
    }
    
    func showHairline() {
        if let hairlineView: UIImageView = findHairlineImageView(containedIn: self) {
            hairlineView.isHidden = false
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
    func numberOfPagesForViewController(_ pageViewController: RGPageViewController) -> Int
    
    /// Asks dataSource to give a view to display as a tab item.
    ///
    /// - parameter pageViewController: the RGPageViewController instance that's subject to
    /// - parameter index: the index of the tab whose view is asked
    ///
    /// - returns: a UIView instance that will be shown as tab at the given index
    func tabViewForPageAtIndex(_ pageViewController: RGPageViewController, index: Int) -> UIView
    
    /// The content for any tab. Return a UIViewController instance and RGPageViewController will use its view to show as content.
    ///
    /// - parameter pageViewController: the RGPageViewController instance that's subject to
    /// - parameter index: the index of the content whose view is asked
    ///
    /// - returns: a UIViewController instance whose view will be shown as content
    func viewControllerForPageAtIndex(_ pageViewController: RGPageViewController, index: Int) -> UIViewController?
}

// MARK: - RGPageViewController Delegate
@objc protocol RGPageViewControllerDelegate {
    /// Delegate objects can implement this method if want to be informed when a page changed.
    ///
    /// - parameter index: the index of the active page
    @objc optional func willChangePageToIndex(_ index: Int, fromIndex from: Int)
    
    /// Delegate objects can implement this method if want to be informed when a page changed.
    ///
    /// - parameter index: the index of the active page
    @objc optional func didChangePageToIndex(_ index: Int)
    
    /// Delegate objects can implement this method if tabs use dynamic width.
    ///
    /// - parameter index: the index of the tab
    /// - returns: the width for the tab at the given index
    @objc optional func widthForTabAtIndex(_ index: Int) -> CGFloat
    
    /// Delegate objects can implement this method if tabs use dynamic height.
    ///
    /// - parameter index: the index of the tab
    /// - returns: the height for the tab at the given index
    @objc optional func heightForTabAtIndex(_ index: Int) -> CGFloat
}
