//
//  UnitsViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DownloadButton

class UnitsViewController: UIViewController, ShareableController, UIViewControllerPreviewingDelegate, ControllerWithStepikPlaceholder {
    var placeholderContainer: StepikPlaceholderControllerContainer = StepikPlaceholderControllerContainer()

    @IBOutlet weak var tableView: StepikTableView!

    /*
     There are 2 ways of instantiating the controller
     1) a Section object
     2) a Unit id - used for instantiation via navigation by LastStep
     */
    var section: Section?
    var unitId: Int?

    var isFirstLoad = true
    var didRefresh = false
    let refreshControl = UIRefreshControl()

    var parentShareBlock: ((UIActivityViewController) -> Void)?

    var downloadTooltip: Tooltip?

    fileprivate func updateTitle() {
        self.navigationItem.title = section?.title ?? NSLocalizedString("Module", comment: "")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        registerPlaceholder(placeholder: StepikPlaceholder(.noConnection), for: .connectionError)

        updateTitle()
        self.navigationItem.backBarButtonItem?.title = " "

        tableView.tableFooterView = UIView()

        tableView.register(UINib(nibName: "UnitTableViewCell", bundle: nil), forCellReuseIdentifier: "UnitTableViewCell")

        let shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(UnitsViewController.shareButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem = shareBarButtonItem

        refreshControl.addTarget(self, action: #selector(UnitsViewController.refresh), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.layoutIfNeeded()

        tableView.emptySetPlaceholder = StepikPlaceholder(.emptyUnits)
        tableView.loadingPlaceholder = StepikPlaceholder(.emptyUnitsLoading)

        refreshControl.beginRefreshing()

        if(traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self, sourceView: view)
        }

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AmplitudeAnalyticsEvents.Lessons.opened(sectionID: section?.id).send()

        if isFirstLoad {
            isFirstLoad = false
            refreshUnits()
        }
    }

    @objc func refresh() {
        refreshUnits()
    }

    var url: String? {
        guard let section = section else {
            return nil
        }
        if let slug = section.course?.slug,
            let module = section.course?.sectionsArray.index(of: section.id) {
            return StepicApplicationsInfo.stepicURL + "/course/" + slug + "/syllabus?module=\(module + 1)"
        } else {
            return nil
        }
    }

    @objc func shareButtonPressed(_ button: UIBarButtonItem) {
        guard let url = self.url else {
            return
        }
        AnalyticsReporter.reportEvent(AnalyticsEvents.Units.shared, parameters: nil)
        DispatchQueue.global(qos: .background).async {
            let shareVC = SharingHelper.getSharingController(url)
            shareVC.popoverPresentationController?.barButtonItem = button
            DispatchQueue.main.async {
                self.present(shareVC, animated: true, completion: nil)
            }
        }
    }

    func share(popoverSourceItem: UIBarButtonItem?, popoverView: UIView?, fromParent: Bool) {
        guard let url = self.url else {
            return
        }
        AnalyticsReporter.reportEvent(AnalyticsEvents.Units.shared, parameters: nil)
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

    func getSectionByUnit(id: Int) {
        //Search for unit by its id locally
        emptyDatasetState = .refreshing
        if let localUnit = Unit.getUnit(id: id) {
            if let localSection = localUnit.section {
                self.section = localSection
                if let index = section?.unitsArray.index(of: id) {
                    currentlyDisplayingUnitIndex = index
                }
                refreshUnits()
                return
            }
            loadUnit(id: id, localUnit: localUnit)
        }

        loadUnit(id: id)
    }

    func loadUnit(id: Int, localUnit: Unit? = nil) {
        emptyDatasetState = .refreshing
        _ = ApiDataDownloader.units.retrieve(ids: [id], existing: (localUnit != nil) ? [localUnit!] : [], refreshMode: .update, success: {
            units in
            guard let unit = units.first else { return }
            let localSection = try! Section.getSections(unit.sectionId).first
            _ = ApiDataDownloader.sections.retrieve(ids: [unit.sectionId], existing: (localSection != nil) ? [localSection!] : [], refreshMode: .update, success: {
                [weak self]
                sections in
                guard let section = sections.first else { return }
                unit.section = section
                self?.section = section
                self?.refreshUnits()
            }, error: {
                _ in
                UIThread.performUI({
                    self.refreshControl.endRefreshing()
                    self.emptyDatasetState = EmptyDatasetState.connectionError
                })
                self.didRefresh = true
            })
        }, error: {
            _ in
            UIThread.performUI({
                self.refreshControl.endRefreshing()
                self.emptyDatasetState = EmptyDatasetState.connectionError
            })
            self.didRefresh = true
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        downloadTooltip?.dismiss()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem?.title = " "
        tableView.reloadData()
        if (self.refreshControl.isRefreshing) {
            let offset = self.tableView.contentOffset
            self.refreshControl.endRefreshing()
            self.refreshControl.beginRefreshing()
            self.tableView.contentOffset = offset
        }

        if let section = section {
            section.loadProgressesForUnits(units: section.units, completion: {
                UIThread.performUI({
                    self.tableView.reloadData()
                })
            })
        }
    }

    var emptyDatasetState: EmptyDatasetState = .empty {
        didSet {
            switch emptyDatasetState {
            case .refreshing:
                isPlaceholderShown = false
                tableView.showLoadingPlaceholder()
            case .empty:
                isPlaceholderShown = false
                tableView.reloadData()
            case .connectionError:
                showPlaceholder(for: .connectionError)
            }
        }
    }

    func refreshUnits(success: (() -> Void)? = nil) {

        guard section != nil else {
            if let id = unitId {
                getSectionByUnit(id: id)
            }
            return
        }

        emptyDatasetState = .refreshing

        updateTitle()

        didRefresh = false
        section?.loadUnits(success: {
            UIThread.performUI({
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            })
            self.didRefresh = true
            success?()
        }, error: {
            UIThread.performUI({
                self.refreshControl.endRefreshing()
                self.emptyDatasetState = EmptyDatasetState.connectionError
            })
            self.didRefresh = true
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let section = section else {
            return
        }

        if segue.identifier == "showSteps" || segue.identifier == "replaceSteps" {
            let dvc = segue.destination as! LessonViewController
            dvc.hidesBottomBarWhenPushed = true
            if let stepsPresentation = sender as? StepsPresentation {

                var stepId: Int? = nil
                var startStepId: Int = 0

                let index = stepsPresentation.index
                if stepsPresentation.isLastStep {
                    if let l = section.units[index].lesson {
                        startStepId = l.stepsArray.count - 1
                        stepId = l.stepsArray.last
                    }
                }

                dvc.initObjects = (lesson: section.units[index].lesson!, startStepId: startStepId, context: .unit)
                dvc.initIds = (stepId: stepId, unitId: section.units[index].id)

                dvc.sectionNavigationDelegate = self
                currentlyDisplayingUnitIndex = index

                let isUnitFirstInSection = index == 0
                let isUnitLastInSection = index == section.units.count - 1
                if let course = section.course {
                    let sectionBefore = course.getSection(before: section)
                    let sectionAfter = course.getSection(after: section)

                    let isSectionFirstInCourse = course.sectionsArray.count == 0 || sectionBefore == nil
                    let isSectionLastInCourse = course.sectionsArray.count == 0 || sectionAfter == nil

                    let isPrevSectionReachable = sectionBefore?.isReachable ?? false
                    let isNextSectionReachable = sectionAfter?.isReachable ?? false

                    var isPrevSectionEmpty = true
                    var isNextSectionEmpty = true

                    if isNextSectionEmpty {
                        var firstNonEmptySection: Section? = sectionAfter
                        while firstNonEmptySection != nil && firstNonEmptySection?.unitsArray.isEmpty ?? false {
                            firstNonEmptySection = course.getSection(after: firstNonEmptySection!)
                        }
                        isNextSectionEmpty = firstNonEmptySection?.unitsArray.isEmpty ?? true
                    }

                    if isPrevSectionEmpty {
                        var firstNonEmptySection: Section? = sectionBefore
                        while firstNonEmptySection != nil && firstNonEmptySection?.unitsArray.isEmpty ?? false {
                            firstNonEmptySection = course.getSection(before: firstNonEmptySection!)
                        }
                        isPrevSectionEmpty = firstNonEmptySection?.unitsArray.isEmpty ?? true
                    }

                    let canPrev = (!isSectionFirstInCourse && isPrevSectionReachable && !isPrevSectionEmpty) || !isUnitFirstInSection
                    let canNext = (!isSectionLastInCourse && isNextSectionReachable && !isNextSectionEmpty) || !isUnitLastInSection
                    dvc.navigationRules = (prev: canPrev, next: canNext)
                } else {
                    dvc.navigationRules = (prev: !isUnitFirstInSection, next: !isUnitLastInSection)
                }
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    var currentlyDisplayingUnitIndex: Int?

    func selectUnitAtIndex(_ index: Int, isLastStep: Bool = false, replace: Bool = false) {
        performSegue(withIdentifier: replace ? "replaceSteps" : "showSteps", sender: StepsPresentation(index: index, isLastStep: isLastStep))
    }

    func goToNextSection() {
        guard let section = section, let course = section.course else {
            return
        }

        // Find first non empty section
        var firstNonEmptySection: Section? = course.getSection(after: section)
        while firstNonEmptySection != nil && firstNonEmptySection?.unitsArray.isEmpty ?? false {
            firstNonEmptySection = course.getSection(after: firstNonEmptySection!)
        }

        guard let nextSection = firstNonEmptySection else {
            // Current section is last or there are no sections w/ units
            return
        }

        // Exam
        guard !nextSection.isExam else {
            showExamAlert { }
            return
        }

        self.section = nextSection
        self.refreshUnits {
            [weak self] in
            self?.selectUnitAtIndex(0, replace: true)
        }
    }

    func goToPrevSection() {
        guard let section = section, let course = section.course else {
            return
        }

        // Find first non empty section
        var firstNonEmptySection: Section? = course.getSection(before: section)
        while firstNonEmptySection != nil && firstNonEmptySection?.unitsArray.isEmpty ?? false {
            firstNonEmptySection = course.getSection(before: firstNonEmptySection!)
        }

        guard let prevSection = firstNonEmptySection else {
            // Current section is first or there are no sections w/ units
            return
        }

        // Exam
        guard !prevSection.isExam else {
            showExamAlert { }
            return
        }

        self.section = prevSection
        self.refreshUnits {
            [weak self] in
            self?.selectUnitAtIndex(prevSection.unitsArray.count - 1, isLastStep: true, replace: true)
        }
    }

    func showExamAlert(seccancel cancelAction: @escaping (() -> Void)) {
        var sUrl = ""
        if let slug = section?.course?.slug {
            sUrl = StepicApplicationsInfo.stepicURL + "/course/" + slug + "/syllabus/"
        }

        let alert = UIAlertController(title: NSLocalizedString("ExamTitle", comment: ""), message: NSLocalizedString("ShowExamInWeb", comment: ""), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Open", comment: ""), style: .default, handler: {
            [weak self]
            _ in
            if let s = self {
                WebControllerManager.sharedManager.presentWebControllerWithURLString(sUrl + "?from_mobile_app=true", inController: s, withKey: "exam", allowsSafari: true, backButtonStyle: .close)
            }
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {
            _ in
            cancelAction()
        }))

        self.present(alert, animated: true, completion: {})
    }

    func clearAllSelection() {
        if let selectedRows = tableView.indexPathsForSelectedRows {
            for indexPath in selectedRows {
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard let units = section?.units else {
            return nil
        }

        let locationInTableView = tableView.convert(location, from: self.view)

        guard let indexPath = tableView.indexPathForRow(at: locationInTableView) else {
            return nil
        }

        guard indexPath.row < units.count else {
            return nil
        }

        guard let cell = tableView.cellForRow(at: indexPath) as? UnitTableViewCell else {
            return nil
        }

        previewingContext.sourceRect = cell.frame

        guard let stepsVC = ControllerHelper.instantiateViewController(identifier: "LessonViewController") as? LessonViewController else {
            return nil
        }

        guard let lesson = units[indexPath.row].lesson else {
            return nil
        }

        AnalyticsReporter.reportEvent(AnalyticsEvents.PeekNPop.Lesson.peeked)
        stepsVC.initObjects = (lesson: lesson, startStepId: 0, context: .unit)
        stepsVC.parentShareBlock = {
            [weak self]
            shareVC in
            AnalyticsReporter.reportEvent(AnalyticsEvents.PeekNPop.Lesson.shared)
            shareVC.popoverPresentationController?.sourceView = cell
            self?.present(shareVC, animated: true, completion: nil)
        }
        return stepsVC
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
        AnalyticsReporter.reportEvent(AnalyticsEvents.PeekNPop.Lesson.popped)
    }
}

class StepsPresentation {
    var index: Int
    var isLastStep: Bool
    init(index: Int, isLastStep: Bool) {
        self.index = index
        self.isLastStep = isLastStep
    }
}

extension UnitsViewController : SectionNavigationDelegate {
    func displayNext() {
        guard let section = section else {
            return
        }
        if let uIndex = currentlyDisplayingUnitIndex {
            if uIndex + 1 < section.units.count {
                selectUnitAtIndex(uIndex + 1, replace: true)
            } else if uIndex + 1 == section.units.count {
                goToNextSection()
            }
        }
    }

    func displayPrev() {
        if let uIndex = currentlyDisplayingUnitIndex {
            if uIndex - 1 >= 0 {
                selectUnitAtIndex(uIndex - 1, isLastStep: true, replace: true)
            } else if uIndex - 1 == -1 {
                goToPrevSection()
            }
        }
    }
}

extension UnitsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectUnitAtIndex((indexPath as NSIndexPath).row)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = section else {
            return 0
        }
        return UnitTableViewCell.heightForCellWithUnit(section.units[(indexPath as NSIndexPath).row])
    }

}

extension UnitsViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let ssection = self.section else {
            return 0
        }
        return ssection.units.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UnitTableViewCell", for: indexPath) as! UnitTableViewCell

        guard let section = section else {
            return cell
        }

        cell.initWithUnit(section.units[(indexPath as NSIndexPath).row], delegate: self)

        if indexPath.row == 0 && TooltipDefaultsManager.shared.shouldShowLessonDownloadsTooltip {
            //Delay here to fight some layout issues
            delay(0.1) {
                [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.downloadTooltip = TooltipFactory.lessonDownload
                strongSelf.downloadTooltip?.show(direction: .up, in: strongSelf.tableView, from: cell.downloadButton)
                TooltipDefaultsManager.shared.didShowOnLessonDownloads = true
            }
        }

        return cell
    }
}

extension UnitsViewController : PKDownloadButtonDelegate {

    fileprivate func askForRemove(okHandler ok: @escaping () -> Void, cancelHandler cancel: @escaping () -> Void) {
        let alert = UIAlertController(title: NSLocalizedString("RemoveVideoTitle", comment: ""), message: NSLocalizedString("RemoveVideoBody", comment: ""), preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Remove", comment: ""), style: UIAlertActionStyle.destructive, handler: {
            _ in
            ok()
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: {
            _ in
            cancel()
        }))

        self.present(alert, animated: true, completion: nil)
    }

    fileprivate func storeLesson(_ lesson: Lesson?, downloadButton: PKDownloadButton!) {
        lesson?.storeVideos(progress: {
            progress in
            UIThread.performUI({downloadButton.stopDownloadButton?.progress = CGFloat(progress)})
            }, completion: {
                downloaded, cancelled in
                if cancelled == 0 {
                    UIThread.performUI({downloadButton.state = PKDownloadButtonState.downloaded})
                } else {
                    UIThread.performUI({downloadButton.state = PKDownloadButtonState.startDownload})
                }
            }, error: {
                _ in
                UIThread.performUI({downloadButton.state = PKDownloadButtonState.startDownload})
        })
    }

    func downloadButtonTapped(_ downloadButton: PKDownloadButton!, currentState state: PKDownloadButtonState) {

        if !didRefresh {
            //TODO : Add alert
            print("wait until the lesson is refreshed")
            return
        }

        guard let section = section else {
            return
        }

        switch (state) {
        case PKDownloadButtonState.startDownload :

            AnalyticsReporter.reportEvent(AnalyticsEvents.Unit.cache, parameters: nil)
            AmplitudeAnalyticsEvents.Downloads.started(content: "lesson").send()

            if !ConnectionHelper.shared.isReachable {
                Messages.sharedManager.show3GDownloadErrorMessage(inController: self.navigationController!)
                print("Not reachable to download")
                return
            }

            downloadButton.state = PKDownloadButtonState.downloading

            if section.units[downloadButton.tag].lesson?.steps.count != 0 {
                storeLesson(section.units[downloadButton.tag].lesson, downloadButton: downloadButton)
            } else {
                section.units[downloadButton.tag].lesson?.loadSteps(completion: {
                    self.storeLesson(section.units[downloadButton.tag].lesson, downloadButton: downloadButton)
                })
            }
            break

        case PKDownloadButtonState.downloading :
            AnalyticsReporter.reportEvent(AnalyticsEvents.Unit.cancel, parameters: nil)
            AmplitudeAnalyticsEvents.Downloads.cancelled(content: "lesson").send()

            downloadButton.state = PKDownloadButtonState.pending
            downloadButton.pendingView?.startSpin()

            section.units[downloadButton.tag].lesson?.cancelVideoStore(completion: {
                DispatchQueue.main.async(execute: {
                    downloadButton.pendingView?.stopSpin()
                    downloadButton.state = PKDownloadButtonState.startDownload
                })
            })
            break

        case PKDownloadButtonState.downloaded :

            AnalyticsReporter.reportEvent(AnalyticsEvents.Unit.delete, parameters: nil)
            AmplitudeAnalyticsEvents.Downloads.deleted(content: "lesson").send()

            downloadButton.state = PKDownloadButtonState.pending
            downloadButton.pendingView?.startSpin()
            askForRemove(okHandler: {
                section.units[downloadButton.tag].lesson?.removeFromStore(completion: {
                    DispatchQueue.main.async(execute: {
                        downloadButton.pendingView?.stopSpin()
                        downloadButton.state = PKDownloadButtonState.startDownload
                    })
                })
            }, cancelHandler: {
                DispatchQueue.main.async(execute: {
                    downloadButton.pendingView?.stopSpin()
                    downloadButton.state = PKDownloadButtonState.downloaded
                })
            })
            break

        case PKDownloadButtonState.pending:
            break
        }
    }
}
