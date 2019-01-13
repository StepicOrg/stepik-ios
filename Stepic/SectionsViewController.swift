//
//  SectionsViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DownloadButton
import Presentr
import SnapKit

class SectionsViewController: UIViewController, ShareableController, UIViewControllerPreviewingDelegate, ControllerWithStepikPlaceholder {
    var placeholderContainer: StepikPlaceholderControllerContainer = StepikPlaceholderControllerContainer()

    @IBOutlet weak var tableView: StepikTableView!
    var completedDownloads = 0

    let refreshControl = UIRefreshControl()
    var didRefresh = false
    var course: Course!
    var moduleId: Int?
    var parentShareBlock: ((UIActivityViewController) -> Void)?
    private var shareBarButtonItem: UIBarButtonItem!
    private var shareTooltip: Tooltip?
    var didJustSubscribe: Bool = false

    var isFirstLoad: Bool = true

    private let notificationSuggestionManager = NotificationSuggestionManager()
    private lazy var notificationsRegistrationService: NotificationsRegistrationServiceProtocol = {
        NotificationsRegistrationService(
            delegate: self,
            presenter: NotificationsRequestAlertPresenter(context: .courseSubscription),
            analytics: .init(source: .courseSubscription)
        )
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerPlaceholder(
            placeholder: StepikPlaceholder(.noConnection, action: { [weak self] in
                self?.refreshSections()
            }),
            for: .connectionError
        )

        LastStepGlobalContext.context.course = course

        self.navigationItem.title = course.title
        tableView.tableFooterView = UIView()
        self.navigationItem.backBarButtonItem?.title = " "

        shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(SectionsViewController.shareButtonPressed(_:)))

        let moreBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "dots_dark"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(SectionsViewController.moreButtonPressed(_:)))

        self.navigationItem.rightBarButtonItems = [moreBarButtonItem, shareBarButtonItem]

        tableView.register(UINib(nibName: "SectionTableViewCell", bundle: nil), forCellReuseIdentifier: "SectionTableViewCell")
        tableView.emptySetPlaceholder = StepikPlaceholder(.emptySections)
        tableView.loadingPlaceholder = StepikPlaceholder(.emptySectionsLoading)

        refreshControl.addTarget(self, action: #selector(SectionsViewController.refreshSections), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.layoutIfNeeded()
        refreshControl.beginRefreshing()

        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension

        if(traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self, sourceView: view)
        }

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        }

        if DefaultsContainer.personalDeadlines.canShowWidget(for: course.id) && course.sectionDeadlines == nil && course.scheduleType == "self_paced" {
            tableView.tableHeaderView = personalDeadlinesWidgetView
            AnalyticsReporter.reportEvent(AnalyticsEvents.PersonalDeadlines.Widget.shown, parameters: ["course": course.id])
        }
    }

    var url: String {
        if let slug = course?.slug {
            return StepicApplicationsInfo.stepicURL + "/course/" + slug + "/syllabus/"
        } else {
            return ""
        }
    }

    //Widget here
    lazy var personalDeadlinesWidgetView: UIView = {
        let widget = PersonalDeadlinesSuggestionWidgetView(frame: CGRect.zero)
        widget.noAction = {
            [weak self] in
            guard let strongSelf = self else {
                return
            }
            AnalyticsReporter.reportEvent(AnalyticsEvents.PersonalDeadlines.Widget.hidden, parameters: ["course": strongSelf.course.id])
            DefaultsContainer.personalDeadlines.declinedWidget(for: strongSelf.course.id)
            strongSelf.tableView.beginUpdates()
            strongSelf.tableView.tableHeaderView = nil
            strongSelf.tableView.endUpdates()
        }
        widget.yesAction = {
            [weak self] in
            guard let strongSelf = self else {
                return
            }
            AnalyticsReporter.reportEvent(AnalyticsEvents.PersonalDeadlines.Widget.clicked, parameters: ["course": strongSelf.course.id])
            strongSelf.requestDeadlines()
            DefaultsContainer.personalDeadlines.acceptedWidget(for: strongSelf.course.id)
            strongSelf.tableView.beginUpdates()
            strongSelf.tableView.tableHeaderView = nil
            strongSelf.tableView.endUpdates()
        }
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        backgroundView.addSubview(widget)

        widget.snp.makeConstraints { make -> Void in
            make.top.leading.equalTo(backgroundView).offset(20)
            make.bottom.trailing.equalTo(backgroundView).offset(-20)
        }
        return backgroundView
    }()

    @objc func moreButtonPressed(_ button: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: course.title, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("CourseInfo", comment: ""), style: .default, handler: {
            _ in
            self.performSegue(withIdentifier: "showCourse", sender: nil)
        }))
        if course.sectionDeadlines != nil {
            alert.addAction(UIAlertAction(title: NSLocalizedString("EditSchedule", comment: ""), style: .default, handler: {
                [weak self]
                _ in
                AnalyticsReporter.reportEvent(AnalyticsEvents.PersonalDeadlines.EditSchedule.changePressed)
                self?.editSchedule()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("DeleteSchedule", comment: ""), style: .destructive, handler: {
                [weak self]
                _ in
                guard let strongSelf = self else {
                    return
                }
                AnalyticsReporter.reportEvent(AnalyticsEvents.PersonalDeadlines.deleted)
                SVProgressHUD.show()
                PersonalDeadlinesService().deleteDeadline(for: strongSelf.course).done { [weak self] _ in
                    SVProgressHUD.dismiss()
                    self?.tableView.reloadData()
                    }.catch {
                        _ in
                        SVProgressHUD.showError(withStatus: nil)
                }
            }))
        } else {
            alert.addAction(UIAlertAction(title: NSLocalizedString("CreateSchedule", comment: ""), style: .default, handler: {
                [weak self]
                _ in
                self?.requestDeadlines()
            }))
        }

        alert.popoverPresentationController?.barButtonItem = button
        present(alert, animated: true, completion: nil)
    }

    @objc func shareButtonPressed(_ button: UIBarButtonItem) {
        share(popoverSourceItem: button, popoverView: nil, fromParent: false)
    }

    @objc func infoButtonPressed(_ button: UIButton) {
        self.performSegue(withIdentifier: "showCourse", sender: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem?.title = " "
        if(self.refreshControl.isRefreshing) {
            let offset = self.tableView.contentOffset
            self.refreshControl.endRefreshing()
            self.refreshControl.beginRefreshing()
            self.tableView.contentOffset = offset
        }
        tableView.layoutTableHeaderView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        AmplitudeAnalyticsEvents.Sections.opened(courseID: course.id, courseTitle: course.title).send()

        if isFirstLoad {
            isFirstLoad = false
            refreshSections()
        }

        if didRefresh {
            course.loadProgressesForSections(sections: course.sections, success: {
                [weak self] in
                self?.tableView.reloadData()
                }, error: {})
        }

        if didJustSubscribe {
            NotificationPermissionStatus.current.done { status in
                if status == .notDetermined {
                    self.notificationsRegistrationService.registerForRemoteNotifications()
                } else {
                    self.showShareTooltip()
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        shareTooltip?.dismiss()
    }

    var emptyDatasetState: EmptyDatasetState = .refreshing {
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

    @objc func refreshSections() {
        didRefresh = false
        emptyDatasetState = .refreshing
        course.loadAllSections(success: {
            UIThread.performUI({
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
                if let m = self.moduleId {
                    if (1...self.course.sectionsArray.count ~= m) && (self.isReachable(section: m - 1)) {
                        self.showSection(section: m - 1)
                    }
                }
            })
            self.didRefresh = true
        }, error: {
            //TODO: Handle error type in section downloading
            UIThread.performUI({
                self.refreshControl.endRefreshing()
                self.emptyDatasetState = EmptyDatasetState.connectionError
                self.tableView.reloadData()
                if let m = self.moduleId {
                    if (1...self.course.sectionsArray.count ~= m) && self.isReachable(section: m - 1) {
                        self.showSection(section: m - 1)
                    }
                }
            })
            self.didRefresh = true
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCourse" {
            let dvc = segue.destination as! CoursePreviewViewController
            dvc.course = course
            dvc.hidesBottomBarWhenPushed = true
        }
        if segue.identifier == "showUnits" {
            let dvc = segue.destination as! UnitsViewController
            dvc.section = course.sections[sender as! Int]
            dvc.hidesBottomBarWhenPushed = true
        }
    }

    private func showShareTooltip() {
        self.shareTooltip?.dismiss()
        self.shareTooltip = TooltipFactory.sharingCourse
        self.shareTooltip?.show(direction: .up, in: nil, from: self.shareBarButtonItem)
        self.didJustSubscribe = false
    }

    // MARK: - Navigation

    func showExamAlert(cancel cancelAction: @escaping (() -> Void)) {
        let alert = UIAlertController(title: NSLocalizedString("ExamTitle", comment: ""), message: NSLocalizedString("ShowExamInWeb", comment: ""), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Open", comment: ""), style: .default, handler: {
            [weak self]
            _ in
            if let s = self {
                WebControllerManager.sharedManager.presentWebControllerWithURLString(s.url + "?from_mobile_app=true", inController: s, withKey: "exam", allowsSafari: true, backButtonStyle: .close)
            }
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {
            _ in
            cancelAction()
        }))

        self.present(alert, animated: true, completion: {})
    }

    func isReachable(section: Int) -> Bool {
        return course.sections[section].isReachable
    }

    func showSection(section sectionId: Int) {
        let section = course.sections[sectionId]
        if section.isExam {
            showExamAlert(cancel: {})
            return
        }

        performSegue(withIdentifier: "showUnits", sender: sectionId)
    }

    func share(popoverSourceItem: UIBarButtonItem?, popoverView: UIView?, fromParent: Bool) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Syllabus.shared, parameters: nil)
        let shareBlock: ((UIActivityViewController) -> Void)? = parentShareBlock
        let url = self.url
        shareTooltip?.dismiss()
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

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        let locationInTableView = tableView.convert(location, from: self.view)

        guard let indexPath = tableView.indexPathForRow(at: locationInTableView) else {
            return nil
        }

        guard indexPath.row < course.sections.count else {
            return nil
        }

        guard let cell = tableView.cellForRow(at: indexPath) as? SectionTableViewCell else {
            return nil
        }

        guard tableView(tableView, shouldHighlightRowAt: indexPath) else {
            return nil
        }

        previewingContext.sourceRect = cell.frame

        guard let unitsVC = ControllerHelper.instantiateViewController(identifier: "UnitsViewController") as? UnitsViewController else {
            return nil
        }
        AnalyticsReporter.reportEvent(AnalyticsEvents.PeekNPop.Section.peeked)
        unitsVC.section = course.sections[indexPath.row]
        unitsVC.parentShareBlock = {
            [weak self]
            shareVC in
            AnalyticsReporter.reportEvent(AnalyticsEvents.PeekNPop.Section.shared)
            shareVC.popoverPresentationController?.sourceView = cell
            self?.present(shareVC, animated: true, completion: nil)
        }
        return unitsVC
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.PeekNPop.Section.popped)
        show(viewControllerToCommit, sender: self)
    }

}

extension SectionsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showSection(section: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return isReachable(section: indexPath.row)
    }

}

extension SectionsViewController : UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return course.sections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SectionTableViewCell", for: indexPath) as! SectionTableViewCell

        let section = course.sections[indexPath.row]
        cell.initWithSection(section, sectionDeadline: course.sectionDeadlines?.first(where: {$0.section == section.id}), delegate: self)

        return cell
    }
}

extension SectionsViewController : PKDownloadButtonDelegate {

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

    fileprivate func storeSection(_ section: Section, downloadButton: PKDownloadButton!) {
        completedDownloads = 0
        let section = course.sections[downloadButton.tag]
        var videosToStore: [Video] = []
        var queuedUnitsCount: Int = 0
        for unit in section.units {
            if unit.lesson?.steps.count != 0 {
                videosToStore += (unit.lesson?.stepVideos ?? []).filter { $0.state == .online }
                queuedUnitsCount += 1
                if queuedUnitsCount == section.units.count {
                    self.storeVideos(videosToStore, downloadButton: downloadButton)
                }
            } else {
                unit.lesson?.loadSteps(completion: {
                    let videos = (unit.lesson?.stepVideos ?? []).filter { $0.state == .online }
                    videosToStore += videos
                    queuedUnitsCount += 1
                    if queuedUnitsCount == section.units.count {
                        self.storeVideos(videosToStore, downloadButton: downloadButton)
                    }
                })
            }
        }
    }

    fileprivate func storeVideos(_ videos: [Video], downloadButton: PKDownloadButton) {
        let quality = VideosInfo.downloadingVideoQuality
        var tasks = [VideoDownloaderTask]()
        for video in videos {
            let nearestQuality = video.getNearestQualityToDefault(quality)
            let url = video.getUrlForQuality(nearestQuality)

            let task = VideoDownloaderTask(videoId: video.id, url: url)
            task.completionReporter = { [weak self] _ in
                video.cachedQuality = nearestQuality
                CoreDataHelper.instance.save()

                self?.completedDownloads += 1
                print("Completed task with id \(task.videoId), video \(self?.completedDownloads ?? -1) of \(videos.count)")

                VideoDownloaderManager.shared.remove(by: task.videoId)
                if self?.completedDownloads == videos.count {
                    UIThread.performUI({downloadButton.state = .downloaded})
                }
            }
            task.failureReporter = { _ in
                VideoDownloaderManager.shared.remove(by: task.videoId)
            }
            tasks.append(task)
        }
        for task in tasks {
            task.progressReporter = { _ in
                let activeTasks = tasks.filter({ $0.state == .active })
                let newProgress = activeTasks.map({ $0.progress }).reduce(0.0, +) / Float(activeTasks.count)

                print("Reported progress \(newProgress), videos count -> \(tasks.count)")

                UIThread.performUI {
                    downloadButton.stopDownloadButton.progress = max(CGFloat(newProgress),
                                                                     downloadButton.stopDownloadButton.progress)
                }
            }

            VideoDownloaderManager.shared.start(task: task)
        }
    }

    func downloadButtonTapped(_ downloadButton: PKDownloadButton!, currentState state: PKDownloadButtonState) {
        if !didRefresh {
            //TODO : Add alert
            print("wait until the section is refreshed")
            return
        }

        switch (state) {
        case PKDownloadButtonState.startDownload :

            AnalyticsReporter.reportEvent(AnalyticsEvents.Section.cache, parameters: nil)
            AmplitudeAnalyticsEvents.Downloads.started(content: "section").send()

            if !ConnectionHelper.shared.isReachable {
                Messages.sharedManager.show3GDownloadErrorMessage(inController: self.navigationController!)
                print("Not reachable to download")
                return
            }

            if course.sections[downloadButton.tag].units.count != 0 {
                UIThread.performUI({downloadButton.state = PKDownloadButtonState.downloading})
                storeSection(course.sections[downloadButton.tag], downloadButton: downloadButton)
            } else {
                UIThread.performUI({downloadButton.state = PKDownloadButtonState.pending})
                course.sections[downloadButton.tag].loadUnits(success: {
                    UIThread.performUI({downloadButton.state = PKDownloadButtonState.downloading})
                    self.storeSection(self.course.sections[downloadButton.tag], downloadButton: downloadButton)
                }, error: {
                    print("Error while downloading section's units")
                })
            }
            break

        case PKDownloadButtonState.downloading :

            AnalyticsReporter.reportEvent(AnalyticsEvents.Section.cancel, parameters: nil)
            AmplitudeAnalyticsEvents.Downloads.cancelled(content: "section").send()

            downloadButton.state = PKDownloadButtonState.pending

            // Cancelation
            let section = course.sections[downloadButton.tag]
            var videos = [Video]()
            for lesson in section.units.compactMap({ $0.lesson }) {
                videos.append(contentsOf: lesson.stepVideos)
            }

            for video in videos {
                if let task = VideoDownloaderManager.shared.get(by: video.id), task.state == .active {
                    task.cancel()
                    VideoDownloaderManager.shared.remove(by: video.id)
                }

                DispatchQueue.main.async(execute: {
                    downloadButton.pendingView?.stopSpin()
                    downloadButton.state = PKDownloadButtonState.startDownload
                })
            }
            break

        case PKDownloadButtonState.downloaded :

            askForRemove(okHandler: {
                AnalyticsReporter.reportEvent(AnalyticsEvents.Section.delete, parameters: nil)
                AmplitudeAnalyticsEvents.Downloads.deleted(content: "section").send()
                downloadButton.state = PKDownloadButtonState.pending

                let section = self.course.sections[downloadButton.tag]
                var videos = [Video]()
                for lesson in section.units.compactMap({ $0.lesson }) {
                    videos.append(contentsOf: lesson.stepVideos)
                }

                var shouldBeRemovedCount = videos.count
                for video in videos {
                    do {
                        try VideoFileManager().removeVideo(videoId: video.id)
                        video.cachedQuality = nil
                        CoreDataHelper.instance.save()

                        shouldBeRemovedCount -= 1
                    } catch { }
                }

                if shouldBeRemovedCount == 0 {
                    DispatchQueue.main.async(execute: {
                        downloadButton.pendingView?.stopSpin()
                        downloadButton.state = PKDownloadButtonState.startDownload
                    })
                }

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

// MARK: - SectionsViewController: NotificationsRegistrationServiceDelegate -

extension SectionsViewController: NotificationsRegistrationServiceDelegate {
    func notificationsRegistrationService(
        _ notificationsRegistrationService: NotificationsRegistrationServiceProtocol,
        shouldPresentAlertFor alertType: NotificationsRegistrationServiceAlertType
    ) -> Bool {
        let canShowAlert = self.notificationSuggestionManager.canShowAlert(context: .courseSubscription)

        if !canShowAlert {
            self.showShareTooltip()
        }

        return canShowAlert
    }

    func notificationsRegistrationService(
        _ notificationsRegistrationService: NotificationsRegistrationServiceProtocol,
        didPresentAlertFor alertType: NotificationsRegistrationServiceAlertType
    ) {
        if alertType == .permission {
            self.notificationSuggestionManager.didShowAlert(context: .courseSubscription)
        }
    }
}
