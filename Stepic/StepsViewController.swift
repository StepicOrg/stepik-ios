//
//  StepsViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 12.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SVProgressHUD

enum StepsControllerPresentationContext {
    case lesson, unit
}

class StepsViewController: RGPageViewController, ShareableController {

    /*
     There are two ways of initializing the StepsViewController
     1) a Lesson object
     2) a Step id , which is used to load the lesson data
     */
    var lesson: Lesson?
    var stepId: Int?
    var unitId: Int?

    var parentShareBlock: ((UIActivityViewController) -> Void)?

    var startStepId: Int = 0

    var canSendViews: Bool = false

    //By default presentation context is unit
    var context: StepsControllerPresentationContext = .unit

    lazy var activityView: UIView = self.initActivityView()

    lazy var warningView: UIView = self.initWarningView()

    let warningViewTitle = NSLocalizedString("ConnectionErrorText", comment: "")

    weak var sectionNavigationDelegate: SectionNavigationDelegate?

    var shouldNavigateToPrev: Bool = false
    var shouldNavigateToNext: Bool = false

    func initWarningView() -> UIView {
        //TODO: change warning image!
        let v = WarningView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), delegate: self, text: warningViewTitle, image: Images.noWifiImage.size250x250, width: UIScreen.main.bounds.width - 16, contentMode: DeviceInfo.isIPad() ? UIViewContentMode.bottom : UIViewContentMode.scaleAspectFit)
        self.view.insertSubview(v, aboveSubview: self.view)
        v.alignTop("50", leading: "0", bottom: "0", trailing: "0", to: self.view)
        return v
    }

    func initActivityView() -> UIView {
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

    fileprivate func updateTitle() {
        self.navigationItem.title = lesson?.title ?? NSLocalizedString("Lesson", comment: "")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateTitle()

        LastStepGlobalContext.context.unitId = unitId // To presenter

        datasource = self
        delegate = self

        if numberOfPages(for: self) == 0 {
            self.view.isUserInteractionEnabled = false
        }

        refreshSteps() //To presenter
    }

    static let stepUpdatedNotification = "StepUpdatedNotification" //To presenter

    fileprivate var tabViewsForStepId = [Int: UIView]() //To presenter

    //To presenter
    func loadLesson() {
        guard let stepId = stepId else {
            print("ERROR: Load lesson without lesson and step id called")
            return
        }

        self.view.isUserInteractionEnabled = false //To view
        self.doesPresentWarningView = false
        self.doesPresentActivityIndicatorView = true

        var step: Step? = nil

        if let localStep = Step.getStepWithId(stepId, unitId: unitId) {
            step = localStep
            if let localLesson = localStep.lesson {
                self.lesson = localLesson
                refreshSteps()
                return
            }
        }

        _ = ApiDataDownloader.steps.retrieve(ids: [stepId], existing: (step != nil) ? [step!] : [], refreshMode: .update, success: {
            steps in

            guard let step = steps.first else {
                return
            }

            var localLesson: Lesson? = nil
            localLesson = Lesson.getLesson(step.lessonId)

            _ = ApiDataDownloader.lessons.retrieve(ids: [step.lessonId], existing: (localLesson != nil) ? [localLesson!] : [], refreshMode: .update, success: {
                [weak self]
                lessons in
                guard let lesson = lessons.first else {
                    return
                }

                self?.lesson = lesson
                step.lesson = lesson
                self?.refreshSteps()
                return

            }, error: {
                _ in
                print("Error while downloading lesson")
                DispatchQueue.main.async {
                    [weak self] in
                    if let s = self {
                        s.view.isUserInteractionEnabled = true //To view
                        s.doesPresentActivityIndicatorView = false //To view
                        if s.numberOfPages(for: s) == 0 { //To view
                            s.doesPresentWarningView = true //To view
                        }
                    }
                }
            })
        }, error: {
            _ in
            print("Error while downloading step")
            DispatchQueue.main.async {
                [weak self] in
                if let s = self {
                    s.view.isUserInteractionEnabled = true //To view
                    s.doesPresentActivityIndicatorView = false //To view
                    if s.numberOfPages(for: s) == 0 { //To view
                        s.doesPresentWarningView = true //To view
                    }
                }
            }
        })
    }

    //TODO: Обновлять шаги только тогда, когда это нужно
    //  Делегировать обновление контента самим контроллерам со степами. Возможно, стоит использовать механизм нотификаций.
    fileprivate func refreshSteps() {

        guard lesson != nil else {
            loadLesson()
            return
        }

        if let section = lesson?.unit?.section,
            let unitId = unitId {
            if let index = section.unitsArray.index(of: unitId) {
                shouldNavigateToPrev = index != 0
                shouldNavigateToNext = index < section.unitsArray.count - 1
            }
        }

        updateTitle() //To view

        if let stepId = stepId {
            if let index = lesson?.stepsArray.index(of: stepId) {
                startStepId = index
                didSelectTab = false
            }
        }

        var prevStepsIds = [Int]()
        if numberOfPages(for: self) == 0 {
            self.view.isUserInteractionEnabled = false //To view
            self.doesPresentWarningView = false //To view
            self.doesPresentActivityIndicatorView = true //To view
        } else {
            if let l = lesson, l.stepsArray.count == l.steps.count {
                prevStepsIds = l.stepsArray
            } else {
                self.view.isUserInteractionEnabled = false //To view
                self.doesPresentWarningView = false //To view
                self.doesPresentActivityIndicatorView = true //To view
            }
        }

        lesson?.loadSteps(completion: {
            [weak self] in
            guard let s = self else {
                return
            }
            let newStepsSet = Set(s.lesson!.stepsArray)
            let prevStepsSet = Set(prevStepsIds)

            //To view
            var reloadBlock : (() -> Void) = {
                [weak self] in
                self?.reloadData()
            }

            if newStepsSet.symmetricDifference(prevStepsSet).count == 0 {
                //need to reload one by one
                reloadBlock = {
                    [weak self] in
                    guard let s = self else {
                        return
                    }
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: StepsViewController.stepUpdatedNotification), object: nil)
                    print("did send step updated notification")
                    //update tab views
                    //To view
                    for index in 0 ..< s.lesson!.steps.count {
                        let tabView = s.pageViewController(s, tabViewForPageAt: index) as? StepTabView
                        if let progress = s.lesson!.steps[index].progress {
                            tabView?.setTab(selected: progress.isPassed, animated: true)
                        }
                    }
                }
            }

            DispatchQueue.main.async {
                [weak self] in
                guard let s = self else {
                    return
                }
                s.view.isUserInteractionEnabled = true //To view
                reloadBlock()
                s.doesPresentWarningView = false //To view
                s.doesPresentActivityIndicatorView = false //To view

                if s.startStepId < s.lesson!.steps.count {
                    if !s.didSelectTab {
                        s.selectTabAtIndex(s.startStepId, updatePage: true) //To view
                        s.didSelectTab = true
                    }
                }
                s.didInitSteps = true
            }
            }, error: {
                [weak self]
                _ in
                guard self != nil else {
                    return
                }
                print("error while loading steps in stepsviewcontroller")
                DispatchQueue.main.async {
                    [weak self] in
                    guard let s = self else {
                        return
                    }
                    s.view.isUserInteractionEnabled = true //To view
                    s.doesPresentActivityIndicatorView = false //To view
                    if s.numberOfPages(for: s) == 0 {
                        s.doesPresentWarningView = true // To view
                    } else {
                        if s.startStepId < s.lesson!.steps.count {
                            if !s.didSelectTab {
                                s.selectTabAtIndex(s.startStepId, updatePage: true) //To view
                                s.didSelectTab = true
                            }
                        }
                    }
                    self?.didInitSteps = true
                }
            }, onlyLesson: context == .lesson)
    }

    var didSelectTab = false
    var didInitSteps = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.backBarButtonItem?.title = " "
        if let l = lesson {
            if !didSelectTab && l.steps.count != 0 && startStepId < l.steps.count && didInitSteps {
                print("\nselected tab for step with id -> \(startStepId)\n")
                didSelectTab = true
                self.selectTabAtIndex(startStepId, updatePage: true)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            return UIColor.mainLightColor
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

    override var tabbarHeight: CGFloat {
        get {
            return 44.0
        }
    }

    override var tabMargin: CGFloat {
        get {
            return 8.0
        }
    }

    var pagesCount = 0

    deinit {
        print("deinit StepsViewController")
    }

    func share(popoverSourceItem: UIBarButtonItem?, popoverView: UIView?, fromParent: Bool) {
        guard let lesson = self.lesson else {
            return
        }
        let url = "\(StepicApplicationsInfo.stepicURL)/lesson/\(lesson.slug)/step/1?from_mobile_app=true"

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

extension StepsViewController : RGPageViewControllerDataSource {
    /// Asks the dataSource for a view to display as a tab item.
    ///
    /// - parameter pageViewController: the `RGPageViewController` instance.
    /// - parameter index: the index of the tab whose view is asked.
    ///
    /// - returns: a `UIView` instance that will be shown as tab at the given index.
    public func pageViewController(_ pageViewController: RGPageViewController, tabViewForPageAt index: Int) -> UIView {

        guard lesson != nil else {
            return UIView()
        }

        //Just a try to fix a strange bug
        if index >= lesson!.steps.count {
            return UIView()
        }

        if let step = lesson?.steps[index] {
            print("initializing tab view for step id \(step.id), progress is \(String(describing: step.progress)))")
            tabViewsForStepId[step.id] = StepTabView(frame: CGRect(x: 0, y: 0, width: 25, height: 25), image: step.block.image, stepId: step.id, passed: step.progress?.isPassed ?? false)

            return tabViewsForStepId[step.id]!
        } else {
            return UIView()
        }
    }

    /// Asks the dataSource about the number of page.
    ///
    /// - parameter pageViewController: the `RGPageViewController` instance.
    ///
    /// - returns: the total number of pages
    public func numberOfPages(for pageViewController: RGPageViewController) -> Int {
        pagesCount = lesson?.steps.count ?? 0
        return pagesCount

    }

    /// Asks the datasource to give a ViewController to display as a page.
    ///
    /// - parameter pageViewController: the `RGPageViewController` instance.
    /// - parameter index: the index of the content whose ViewController is asked.
    ///
    /// - returns: a `UIViewController` instance whose view will be shown as content.
    public func pageViewController(_ pageViewController: RGPageViewController, viewControllerForPageAt index: Int) -> UIViewController? {
        if let lesson = lesson {
            //Just a try to fix a strange bug
            if index >= lesson.steps.count {
                return nil
            }

            if lesson.steps[index].block.name == "video" {
                let stepController = storyboard?.instantiateViewController(withIdentifier: "VideoStepViewController") as! VideoStepViewController
                stepController.video = lesson.steps[index].block.video!
                stepController.step = lesson.steps[index]
//                stepController.parentNavigationController = self.navigationController
                stepController.startStepId = startStepId
                stepController.stepId = index + 1
                stepController.lessonSlug = lesson.slug
                stepController.nItem = self.navigationItem

                if let assignments = lesson.unit?.assignments {
                    if index < assignments.count {
                        stepController.assignment = assignments[index]
                    }
                }

                stepController.startStepBlock = {
                    [weak self] in
                    self?.canSendViews = true
                }
                stepController.shouldSendViewsBlock = {
                    [weak self] in
                    return self?.canSendViews ?? false
                }

                if context == .unit {
                    //                    stepController.assignment = lesson.unit?.assignments[index]

                    if index == 0 && shouldNavigateToPrev {
                        stepController.prevLessonHandler = {
                            [weak self] in
                            self?.sectionNavigationDelegate?.displayPrev()
                        }
                    }

                    if index == lesson.steps.count - 1 && shouldNavigateToNext {
                        stepController.nextLessonHandler = {
                            [weak self] in
                            self?.sectionNavigationDelegate?.displayNext()
                        }
                    }
                }

                return stepController
            } else {
                let stepController = storyboard?.instantiateViewController(withIdentifier: "WebStepViewController") as! WebStepViewController
//                stepController.stepsVC = self
                stepController.step = lesson.steps[index]
                stepController.lesson = lesson
                stepController.stepId = index + 1
                stepController.nItem = self.navigationItem
                stepController.startStepId = startStepId

                if let assignments = lesson.unit?.assignments {
                    if index < assignments.count {
                        stepController.assignment = assignments[index]
                    }
                }

                stepController.startStepBlock = {
                    [weak self] in
                    self?.canSendViews = true
                }
                stepController.shouldSendViewsBlock = {
                    [weak self] in
                    return self?.canSendViews ?? false
                }
                stepController.lessonSlug = lesson.slug
                if context == .unit {
                    //                    stepController.assignment = lesson.unit?.assignments[index]

                    if index == 0 && shouldNavigateToPrev {
                        stepController.prevLessonHandler = {
                            [weak self] in
                            self?.sectionNavigationDelegate?.displayPrev()
                        }
                    }

                    if index == lesson.steps.count - 1 && shouldNavigateToNext {
                        stepController.nextLessonHandler = {
                            [weak self] in
                            self?.sectionNavigationDelegate?.displayNext()
                        }
                    }
                }

                return stepController
            }
        }
        return nil
    }

}

extension StepsViewController : RGPageViewControllerDelegate {

    /// Delegate objects can implement this method if tabs use dynamic width or to overwrite the default width for tabs.
    ///
    /// - parameter pageViewController: the `RGPageViewController` instance.
    /// - parameter index: the index of the tab.
    ///
    /// - returns: the width for the tab at the given index.
    func pageViewController(_ pageViewController: RGPageViewController, widthForTabAt index: Int) -> CGFloat {
        return 44.0
    }

    /// Delegate objects can implement this method if tabs use dynamic height or to overwrite the default height for tabs.
    ///
    /// - parameter pageViewController: the `RGPageViewController` instance.
    /// - parameter index: the index of the tab.
    ///
    /// - returns: the height for the tab at the given index.
    func pageViewController(_ pageViewController: RGPageViewController, heightForTabAt index: Int) -> CGFloat {
        return 44.0
    }
}

extension StepsViewController : WarningViewDelegate {
    func didPressButton() {
        refreshSteps()
    }
}
