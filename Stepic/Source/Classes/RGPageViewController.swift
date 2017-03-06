//
//  RGPageViewController.swift
//  RGViewPager
//
//  Created by Ronny Gerasch on 08.11.14.
//  Copyright (c) 2014 Ronny Gerasch. All rights reserved.
//

import Foundation
import UIKit

// MARK: - RGTabbarStyle
public enum RGTabbarStyle {
  case solid
  case blurred
}

// MARK: - RGTabStyle
public enum RGTabStyle {
  case none
  case inactiveFaded
}

// MARK: - RGTabbarPosition
public enum RGTabbarPosition {
  case top
  case bottom
  case left
  case right
}

// MARK: - RGPageViewController
open class RGPageViewController: UIViewController {
  // MARK: - Protocols
  public weak var datasource: RGPageViewControllerDataSource?
  public weak var delegate: RGPageViewControllerDelegate?
  internal var pageViewScrollDelegate: UIScrollViewDelegate?
  
  // MARK: - Variables
  private var needsSetup: Bool = true
  private var animatingToTab: Bool = false
  // Pager
  internal var pager: UIPageViewController!
  internal var pageCount: Int = 0
  private var currentPageIndex: Int = 0
  var pagerScrollView: UIScrollView?
  internal var pageViewControllers: Array<UIViewController?> = Array<UIViewController>()
  open var pagerOrientation: UIPageViewControllerNavigationOrientation {
    return .horizontal
  }
  // Tabs
  internal var tabbar: UIView!
  internal var tabScrollView: UICollectionView!
  open var currentTabIndex: Int = 0
  open var tabWidth: CGFloat {
    return UIScreen.main.bounds.size.width / 3
  }
  open var tabbarWidth: CGFloat {
    return 100
  }
  open var tabbarHeight: CGFloat {
    return 38
  }
  open var tabIndicatorWidthOrHeight: CGFloat {
    return 2
  }
  open var tabIndicatorColor: UIColor {
    return UIColor.lightGray
  }
  open var tabMargin: CGFloat {
    return 0
  }
  open var tabStyle: RGTabStyle {
    return .none
  }
  // Tabbar
  open var tabbarHidden: Bool {
    return false
  }
  open var tabbarStyle: RGTabbarStyle {
    return .blurred
  }
  open var tabbarPosition: RGTabbarPosition {
    return .top
  }
  open var barTintColor: UIColor? {
    return nil
  }
  
  // MARK: - Constructors
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  // MARK: - ViewController life cycle
  open override func viewDidLoad() {
    super.viewDidLoad()
    
    initPager()
    initTabBar()
    initTabScrollView()
    
    layoutSubviews()
  }
  
  open override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    if needsSetup {
      setupSelf()
      
      tabScrollView.layoutIfNeeded()
      
      let cellIsVisible = tabScrollView.indexPathsForVisibleItems.contains(where: {$0.item == currentTabIndex})
      
      if !cellIsVisible {
        let indexPath = IndexPath(item: currentTabIndex, section: 0)
        
        switch tabbarPosition {
        case .top, .bottom:
          tabScrollView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        case .left, .right:
          tabScrollView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        }
      }
    }
  }
  
  open override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.navigationBar.showHairline()
  }
  
  // MARK: - Functions
  private func initPager() {
    pager = UIPageViewController(transitionStyle: .scroll, navigationOrientation: pagerOrientation, options: nil)
    
    let pagerX: CGFloat = tabbarHidden || tabbarPosition != .left ? 0 : tabbarWidth
    let pagerWidth: CGFloat = tabbarPosition == .top || tabbarPosition == .bottom ? view.bounds.size.width : view.bounds.size.width - (tabbarHidden ? 0 : tabbarWidth)
    
    pager.view.frame = CGRect(
      x: pagerX,
      y: 0,
      width: pagerWidth,
      height: view.bounds.size.height
    )
    
    addChildViewController(pager)
    
    pagerScrollView = pager.view.subviews.first as? UIScrollView
    pageViewScrollDelegate = pagerScrollView?.delegate
    
    pagerScrollView?.scrollsToTop = false
    pagerScrollView?.delegate = self
    
    view.addSubview(pager.view)
    
    pager.didMove(toParentViewController: self)
  }
  
  private func initTabBar() {
    switch tabbarStyle {
    case .blurred:
      tabbar = UIToolbar()
      
      if let tabbar = self.tabbar as? UIToolbar {
        tabbar.barTintColor = barTintColor
        tabbar.isTranslucent = true
        tabbar.delegate = self
      }
    case .solid:
      tabbar = UIView()
      
      tabbar.backgroundColor = barTintColor
    }
    
    tabbar.isHidden = tabbarHidden
  }
  
  private func initTabScrollView() {
    tabScrollView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    tabScrollView.backgroundColor = UIColor.clear
    tabScrollView.scrollsToTop = false
    tabScrollView.isOpaque = false
    tabScrollView.showsHorizontalScrollIndicator = false
    tabScrollView.showsVerticalScrollIndicator = false
    tabScrollView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "rgTabCell")
    
    tabbar.addSubview(tabScrollView)
    
    view.addSubview(tabbar)
  }
  
  private func layoutSubviews() {
    tabbar.translatesAutoresizingMaskIntoConstraints = false
    tabScrollView.translatesAutoresizingMaskIntoConstraints = false
    
    switch tabbarPosition {
    case .top:
      layoutTabbarTop()
    case .bottom:
      layoutTabbarBottom()
    case .left:
      layoutTabbarLeft()
    case .right:
      layoutTabbarRight()
    }
  }
  
  private func layoutTabbarTop() {
    (tabScrollView.collectionViewLayout as! UICollectionViewFlowLayout).scrollDirection = .horizontal
    
    if let navigationController = self.navigationController, !navigationController.navigationBar.isHidden {
      navigationController.navigationBar.hideHairline()
    }
    
    NSLayoutConstraint(item: tabbar, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabbar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabbar, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabbar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: tabbarHeight).isActive = true
    
    NSLayoutConstraint(item: tabScrollView, attribute: .leading, relatedBy: .equal, toItem: tabbar, attribute: .leading, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabScrollView, attribute: .trailing, relatedBy: .equal, toItem: tabbar, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabScrollView, attribute: .top, relatedBy: .equal, toItem: tabbar, attribute: .top, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabScrollView, attribute: .bottom, relatedBy: .equal, toItem: tabbar, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
  }
  
  private func layoutTabbarBottom() {
    (tabScrollView.collectionViewLayout as! UICollectionViewFlowLayout).scrollDirection = .horizontal
    
    NSLayoutConstraint(item: tabbar, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabbar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabbar, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabbar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: tabbarHeight).isActive = true
    
    NSLayoutConstraint(item: tabScrollView, attribute: .leading, relatedBy: .equal, toItem: tabbar, attribute: .leading, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabScrollView, attribute: .trailing, relatedBy: .equal, toItem: tabbar, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabScrollView, attribute: .top, relatedBy: .equal, toItem: tabbar, attribute: .top, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabScrollView, attribute: .bottom, relatedBy: .equal, toItem: tabbar, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
  }
  
  private func layoutTabbarLeft() {
    (tabScrollView.collectionViewLayout as! UICollectionViewFlowLayout).scrollDirection = .vertical
    
    NSLayoutConstraint(item: tabbar, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabbar, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabbar, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: tabbarWidth).isActive = true
    
    if tabbarStyle == .blurred {
      NSLayoutConstraint(item: tabbar, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    } else {
      NSLayoutConstraint(item: tabbar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).isActive = true
      
      var scrollTop: CGFloat = UIApplication.shared.isStatusBarHidden ? 0 : 20
      
      if let navigationController = self.navigationController, !navigationController.navigationBar.isHidden {
        scrollTop += 44
      }
      
      var edgeInsets: UIEdgeInsets = tabScrollView.contentInset
      
      edgeInsets.top = scrollTop
      edgeInsets.bottom = 0
      
      tabScrollView.contentInset = edgeInsets
      tabScrollView.scrollIndicatorInsets = edgeInsets
    }
    
    NSLayoutConstraint(item: tabScrollView, attribute: .leading, relatedBy: .equal, toItem: tabbar, attribute: .leading, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabScrollView, attribute: .trailing, relatedBy: .equal, toItem: tabbar, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabScrollView, attribute: .top, relatedBy: .equal, toItem: tabbar, attribute: .top, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabScrollView, attribute: .bottom, relatedBy: .equal, toItem: tabbar, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
  }
  
  private func layoutTabbarRight() {
    (tabScrollView.collectionViewLayout as! UICollectionViewFlowLayout).scrollDirection = .vertical

    
    NSLayoutConstraint(item: tabbar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabbar, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabbar, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: tabbarWidth).isActive = true
    
    if tabbarStyle == .blurred {
      NSLayoutConstraint(item: tabbar, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    } else {
      NSLayoutConstraint(item: tabbar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).isActive = true
      
      var scrollTop: CGFloat = UIApplication.shared.isStatusBarHidden ? 0 : 20
      
      if let navigationController = self.navigationController, !navigationController.navigationBar.isHidden {
        scrollTop += 44
      }
      
      var edgeInsets: UIEdgeInsets = tabScrollView.contentInset
      
      edgeInsets.top = scrollTop
      edgeInsets.bottom = 0
      
      tabScrollView.contentInset = edgeInsets
      tabScrollView.scrollIndicatorInsets = edgeInsets
    }
    
    NSLayoutConstraint(item: tabScrollView, attribute: .leading, relatedBy: .equal, toItem: tabbar, attribute: .leading, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabScrollView, attribute: .trailing, relatedBy: .equal, toItem: tabbar, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabScrollView, attribute: .top, relatedBy: .equal, toItem: tabbar, attribute: .top, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: tabScrollView, attribute: .bottom, relatedBy: .equal, toItem: tabbar, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
  }
  
  func setupSelf() {
    pageCount = datasource?.numberOfPages(for: self) ?? 0
    
    pageViewControllers.removeAll()
    pageViewControllers = Array<UIViewController?>(repeating: nil, count: pageCount)
    
    pager.dataSource = self
    pager.delegate = self
    
    tabScrollView.dataSource = self
    tabScrollView.delegate = self
    
    selectTabAtIndex(currentTabIndex, updatePage: true)
    
    needsSetup = false
  }
  
  internal func tabViewAtIndex(_ index: Int) -> RGTabView? {
    if let tabViewContent = datasource?.pageViewController(self, tabViewForPageAt: index) {
      var tabView: RGTabView
      var frame: CGRect = .zero
      var orientation: RGTabOrientation = .horizontalTop
      
      switch tabbarPosition {
      case .top:
        if let theWidth = delegate?.pageViewController?(self, widthForTabAt: index) {
          frame = CGRect(
            x: 0,
            y: 0,
            width: theWidth,
            height: tabbarHeight
          )
        } else {
          frame = CGRect(
            x: 0,
            y: 0,
            width: tabWidth,
            height: tabbarHeight
          )
        }
      case .bottom:
        if let theWidth = delegate?.pageViewController?(self, widthForTabAt: index) {
          frame = CGRect(
            x: 0,
            y: 0,
            width: theWidth,
            height: tabbarHeight
          )
        } else {
          frame = CGRect(
            x: 0,
            y: 0,
            width: tabWidth,
            height: tabbarHeight
          )
        }
        
        orientation = .horizontalBottom
      case .left:
        if let theHeight = delegate?.pageViewController?(self, heightForTabAt: index) {
          frame = CGRect(
            x: 0,
            y: 0,
            width: tabbarWidth,
            height: theHeight
          )
        } else {
          frame = CGRect(
            x: 0,
            y: 0,
            width: tabbarWidth,
            height: tabbarWidth
          )
        }
        
        orientation = .verticalLeft
      case .right:
        if let theHeight = delegate?.pageViewController?(self, heightForTabAt: index) {
          frame = CGRect(
            x: 0,
            y: 0,
            width:
            tabbarWidth,
            height: theHeight
          )
        } else {
          frame = CGRect(
            x: 0,
            y: 0,
            width: tabbarWidth,
            height: tabbarWidth
          )
        }
        
        orientation = .verticalRight
      }
      
      tabView = RGTabView(
        frame: frame,
        indicatorColor: tabIndicatorColor,
        indicatorHW: tabIndicatorWidthOrHeight,
        style: tabStyle,
        orientation: orientation
      )
      
      tabView.clipsToBounds = true
      tabView.addSubview(tabViewContent)
      
      tabViewContent.center = tabView.center
      
      return tabView
    }
    
    return nil
  }
  
  internal func selectTabAtIndex(_ index: Int, updatePage: Bool) {
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
    
    delegate?.pageViewController?(self, didChangePageTo: index)
  }
  
  private func updateTabIndex(_ index: Int, animated: Bool) {
    deselectCurrentTab()
    selectTab(at: index, animated: animated)
    
    currentTabIndex = index
  }
  
  private func deselectCurrentTab() {
    let indexPath = IndexPath(item: currentTabIndex, section: 0)
    let cell = tabScrollView.cellForItem(at: indexPath) ?? collectionView(tabScrollView, cellForItemAt: indexPath)
    
    if let tabView = cell.contentView.subviews.first as? RGTabView {
      tabView.selected = false
    }
  }
  
  private func selectTab(at index: Int, animated: Bool) {
    let indexPath = IndexPath(item: index, section: 0)
    let cell = tabScrollView.cellForItem(at: indexPath) ?? collectionView(tabScrollView, cellForItemAt: indexPath)
    
    if let tabView = cell.contentView.subviews.first as? RGTabView {
      tabView.selected = true
    }
    
    updateTabScrollPosition(at: index, animated: animated)
  }
  
  private func updateTabScrollPosition(at index: Int, animated: Bool) {
    let nextIndex = index >= currentTabIndex ? min(index + 1, pageCount - 1) : max(0, index - 1)
    let indexPath = IndexPath(item: nextIndex, section: 0)
    let cell = tabScrollView.cellForItem(at: indexPath) ?? collectionView(tabScrollView, cellForItemAt: indexPath)
    
    var cellFrame = cell.frame
    
    switch tabbarPosition {
    case .top, .bottom:
      cellFrame.origin.x -= (nextIndex == 0 ? tabMargin : tabMargin / 2.0)
      cellFrame.size.width += tabMargin
    case .left, .right:
      cellFrame.origin.y -= tabMargin / 2.0
      cellFrame.size.height += tabMargin
    }
    
    let rect = tabScrollView.convert(cellFrame, to: tabScrollView.superview)
    let cellIsVisible = tabScrollView.frame.contains(rect)
    
    if !cellIsVisible {
      if index == nextIndex {
        tabScrollView.scrollRectToVisible(cellFrame, animated: animated)
        
        return
      }
      
      if index > currentTabIndex {
        switch tabbarPosition {
        case .top, .bottom:
          cellFrame.size.width /= 3
        case .left, .right:
          cellFrame.size.height /= 3
        }
      } else {
        switch tabbarPosition {
        case .top, .bottom:
          cellFrame.origin.x += cellFrame.size.width - (cellFrame.size.width / 3)
          cellFrame.size.width /= 3
        case .left, .right:
          cellFrame.origin.y += cellFrame.size.height - (cellFrame.size.height / 3)
          cellFrame.size.height /= 3
        }
      }
      
      tabScrollView.scrollRectToVisible(cellFrame, animated: animated)
    }
  }
  
  private func updatePager(_ index: Int) {
    guard let viewController = viewControllerAtIndex(index) else {
      return
    }
    
    if index == currentPageIndex {
      pager.setViewControllers([viewController], direction: .forward, animated: false, completion: { [weak self] _ -> Void in
        self?.animatingToTab = false
      })
    } else if !(index + 1 == currentPageIndex || index - 1 == currentPageIndex) {
      let direction: UIPageViewControllerNavigationDirection = index < currentPageIndex ? .reverse : .forward
        
      pager.setViewControllers([viewController], direction: direction, animated: true, completion: { [weak self] (finished) -> Void in
        self?.animatingToTab = false
        
        DispatchQueue.main.async {
          self?.pager.setViewControllers([viewController], direction: direction, animated: false, completion: nil)
        }
      })
    } else {
      pager.setViewControllers([viewController], direction: index < currentPageIndex ? .reverse : .forward, animated: true, completion: { [weak self] (Bool) -> Void in
        self?.animatingToTab = false
      })
    }
    
    currentPageIndex = index
  }
  
  internal func indexForViewController(_ viewController: UIViewController) -> Int? {
    return pageViewControllers.index(where: { $0 == viewController })
  }
  
  open func reloadData() {
    pageCount = datasource?.numberOfPages(for: self) ?? 0
    
    pageViewControllers.removeAll()
    pageViewControllers = Array<UIViewController?>(repeating: nil, count: pageCount)
    
    tabScrollView.reloadData()
    
    selectTabAtIndex(currentTabIndex, updatePage: true)
  }
}
