//
//  CoursePreviewViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 30.09.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SVProgressHUD
import MediaPlayer

class CoursePreviewViewController: UIViewController, ShareableController {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var videoWebView: UIWebView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var thumbnailImageView: UIImageView!

    var video: Video!
    var moviePlayer: MPMoviePlayerController?
    var parentShareBlock: ((UIActivityViewController) -> Void)?

    var course: Course? = nil {
        didSet {
            if let c = course {
                if c.summary != "" {
                    textData[0] += [(NSLocalizedString("Summary", comment: ""), c.summary)]
                    heights[0] += [TitleTextTableViewCell.heightForCellWith(title: NSLocalizedString("Summary", comment: ""), text: c.summary)]
                }
                textData[0] += [("", "")]
                heights[0] += [0]
                if c.courseDescription != "" {
                    textData[1] += [(NSLocalizedString("Description", comment: ""), c.courseDescription)]
                    heights[1] += [TitleTextTableViewCell.heightForCellWith(title: NSLocalizedString("Description", comment: ""), text: c.courseDescription)]
                }
                if c.workload != "" {
                    textData[1] += [(NSLocalizedString("Workload", comment: ""), c.workload)]
                    heights[1] += [TitleTextTableViewCell.heightForCellWith(title: NSLocalizedString("Workload", comment: ""), text: c.workload)]
                }
                if c.certificate != "" {
                    textData[1] += [(NSLocalizedString("Certificate", comment: ""), c.certificate)]
                    heights[1] += [TitleTextTableViewCell.heightForCellWith(title: NSLocalizedString("Certificate", comment: ""), text: c.certificate)]
                }
                if c.audience != "" {
                    textData[1] += [(NSLocalizedString("Audience", comment: ""), c.audience)]
                    heights[1] += [TitleTextTableViewCell.heightForCellWith(title: NSLocalizedString("Audience", comment: ""), text: c.audience)]
                }
                if c.format != "" {
                    textData[1] += [(NSLocalizedString("Format", comment: ""), c.format)]
                    heights[1] += [TitleTextTableViewCell.heightForCellWith(title: NSLocalizedString("Format", comment: ""), text: c.format)]
                }
                if c.requirements != "" {
                    textData[1] += [(NSLocalizedString("Requirements", comment: ""), c.requirements)]
                    heights[1] += [TitleTextTableViewCell.heightForCellWith(title: NSLocalizedString("Requirements", comment: ""), text: c.requirements)]
                }
            }
        }

    }

    var displayingInfoType: DisplayingInfoType = .overview {
        didSet {
            if displayingInfoType == .syllabus && didLoad {
                tableView.reloadData()
            }
        }
    }

    var didLoad: Bool = false

    fileprivate func initBarButtonItems(dropAvailable: Bool) {
        let shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(CoursePreviewViewController.shareButtonPressed(_:)))
        if dropAvailable {
            let moreBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "dots_dark"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(CoursePreviewViewController.moreButtonPressed(_:)))
            self.navigationItem.rightBarButtonItems = [moreBarButtonItem, shareBarButtonItem]
        } else {
            self.navigationItem.rightBarButtonItem = shareBarButtonItem
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TitleTextTableViewCell", bundle: nil), forCellReuseIdentifier: "TitleTextTableViewCell")

        self.navigationItem.backBarButtonItem?.title = ""

        tableView.tableFooterView = UIView()

        tableView.estimatedRowHeight = 44.0
        videoWebView.scrollView.isScrollEnabled = false
        videoWebView.scrollView.bouncesZoom = false

        if let c = course {
            sectionTitles = []
            for section in c.sections {
                sectionTitles += [section.title]
            }
            print(sectionTitles)
            tableView.reloadData()
            resetHeightConstraints()
            if let introVideo = c.introVideo {
                setIntroMode(fromVideo: true)
                setupPlayerWithVideo(introVideo)
            } else {
                setIntroMode(fromVideo: false)
                loadVimeoURL(URL(string: c.introURL))
            }
            updateSections()

            initBarButtonItems(dropAvailable: c.enrolled)
        }
        didLoad = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.navigationController as? StyledNavigationViewController)?.setStatusBarStyle()
    }

    func shareButtonPressed(_ button: UIBarButtonItem) {
        share(popoverSourceItem: button, popoverView: nil, fromParent: false)
    }

    func share(popoverSourceItem: UIBarButtonItem?, popoverView: UIView?, fromParent: Bool) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.CourseOverview.shared, parameters: nil)

        let shareBlock: ((UIActivityViewController) -> Void)? = parentShareBlock
        if let slug = course?.slug {
            DispatchQueue.global(qos: .default).async {
                [weak self] in
                let shareVC = SharingHelper.getSharingController(StepicApplicationsInfo.stepicURL + "/course/" + slug + "/")
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
    }

    func moreButtonPressed(_ button: UIBarButtonItem) {

        guard let c = course else {
            return
        }

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: NSLocalizedString("DropCourse", comment: ""), style: .destructive, handler: {
            [weak self]
            _ in
            self?.askForUnenroll(unenroll: {
                [weak self] in
                SVProgressHUD.show()
                button.isEnabled = false
                _ = AuthManager.sharedManager.joinCourseWithId(c.id, delete: true, success : {
                    SVProgressHUD.showSuccess(withStatus: "")
                    button.isEnabled = true
                    c.enrolled = false
                    CoreDataHelper.instance.save()
                    CoursesJoinManager.sharedManager.deletedCourses += [c]
                    WatchDataHelper.parseAndAddPlainCourses(WatchCoursesDisplayingHelper.getCurrentlyDisplayingCourses())
                    self?.initBarButtonItems(dropAvailable: c.enrolled)
                    _ = self?.navigationController?.popToRootViewController(animated: true)
                    }, error: {
                        status in
                        SVProgressHUD.showError(withStatus: status)
                        button.isEnabled = true
                })
            })
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))

        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = button
        }

        self.present(alert, animated: true)
    }

    fileprivate func updateSections() {
        if let c = course {
            let successBlock = {
                [weak self] in
                self?.sectionTitles = []
                for section in c.sections {
                    self?.sectionTitles += [section.title]
                }
//                print(self?.sectionTitles)
                self?.isErrorWhileLoadingSections = false
                self?.isLoadingSections = false
                UIThread.performUI { self?.tableView.reloadData() }
            }

            let errorBlock = {
                [weak self] in
                self?.isErrorWhileLoadingSections = true
                self?.isLoadingSections = false
                UIThread.performUI { self?.tableView.reloadData() }
            }

            isLoadingSections = true
//            if AuthInfo.shared.isAuthorized {
                c.loadAllSections(success: successBlock, error: errorBlock, withProgresses: false)
//            } else {
//                c.loadSectionsWithoutAuth(success: successBlock, error: errorBlock)
//            }
        }
    }

    var sectionTitles = [String]()
    var isErrorWhileLoadingSections: Bool = false
    var isLoadingSections: Bool = false

    fileprivate func resetHeightConstraints() {
        let v = self.tableView.tableHeaderView
        var headerframe = v?.frame
        headerframe?.size.height = getPlayerHeight()
        v?.frame = headerframe ?? CGRect.zero
        tableView.tableHeaderView = v

        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.setNeedsUpdateConstraints()
        tableView.updateConstraintsIfNeeded()
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    fileprivate func loadVimeoURL(_ url: URL?) {
        guard let url = url else {
            return
        }
        DispatchQueue.global(qos: .default).async {
            self.videoWebView.loadRequest(URLRequest(url: url))
        }
    }

    fileprivate func setIntroMode(fromVideo: Bool) {
        videoWebView.isHidden = fromVideo
        playButton.isHidden = !fromVideo
        thumbnailImageView.isHidden = !fromVideo
    }

    var imageTapHelper: ImageTapHelper!

    fileprivate func setupPlayerWithVideo(_ video: Video) {
        thumbnailImageView.sd_setImage(with: URL(string: video.thumbnailURL), placeholderImage: Images.videoPlaceholder)

        imageTapHelper = ImageTapHelper(imageView: thumbnailImageView, action: {
            [weak self]
            _ in
            self?.playVideo()
        })

        self.video = video

        if video.urls.count == 0 {
            videoWebView.isHidden = true
            playButton.isHidden = true
            thumbnailImageView.isHidden = false
            return
        }

        self.moviePlayer = MPMoviePlayerController(contentURL: videoURL)
        if let player = self.moviePlayer {
            player.scalingMode = MPMovieScalingMode.aspectFit
            player.isFullscreen = false
            player.movieSourceType = MPMovieSourceType.file
            player.repeatMode = MPMovieRepeatMode.none
            self.contentView.addSubview(player.view)
            NotificationCenter.default.addObserver(self, selector: #selector(CoursePreviewViewController.willExitFullscreen), name: NSNotification.Name.MPMoviePlayerWillExitFullscreen, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CoursePreviewViewController.didExitFullscreen), name: NSNotification.Name.MPMoviePlayerDidExitFullscreen, object: nil)

            _ = self.moviePlayer?.view.alignLeading("0", trailing: "0", to: self.contentView)
            _ = self.moviePlayer?.view.alignTop("0", bottom: "0", to: self.contentView)
            self.moviePlayer?.view.isHidden = true
        }
    }

    var fullScreenWasPlaying: Bool = false

    func didExitFullscreen() {
        if fullScreenWasPlaying {
            self.moviePlayer?.play()
        }
    }

    func willExitFullscreen() {
        fullScreenWasPlaying = self.moviePlayer?.playbackState == MPMoviePlaybackState.playing
    }

    var videoURL: URL {
        return video.getUrlForQuality(VideosInfo.watchingVideoQuality)
    }

    func reload(reloadViews rv: Bool) {

        self.moviePlayer?.movieSourceType = MPMovieSourceType.file
        self.moviePlayer?.contentURL = videoURL

        if rv {
            setControls(playing: false)
        }
    }

    var isShowingPlayer: Bool {
        return !(self.moviePlayer?.view.isHidden ?? true)
    }

    func setControls(playing p: Bool) {
        self.moviePlayer?.view.isHidden = !p
        self.thumbnailImageView.isHidden = p
        self.playButton.isHidden = p
    }

    func playVideo() {
        if ConnectionHelper.shared.reachability.isReachableViaWiFi() || ConnectionHelper.shared.reachability.isReachableViaWWAN() {
            setControls(playing: true)
            self.moviePlayer?.play()
        }
    }

    @IBAction func playButtonPressed(_ sender: UIButton) {
        playVideo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    fileprivate var textData: [[(String, String)]] = [
        //Overview
        [],
        //Detailed
        []
    ]

    fileprivate var heights: [[CGFloat]] = [
        //Overview
        [],
        //Detailed
        []
    ]

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSections" {
            let dvc = segue.destination as! SectionsViewController
            dvc.course = course
        }
    }

    @IBAction func displayingSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        displayingInfoType = DisplayingInfoType(rawValue: sender.selectedSegmentIndex) ?? .overview
        reloadTableView()
    }

    @IBAction func joinButtonPressed(_ sender: UIButton) {
        if !StepicApplicationsInfo.doesAllowCourseUnenrollment {
            return
        }

        if !AuthInfo.shared.isAuthorized {
            AnalyticsReporter.reportEvent(AnalyticsEvents.CourseOverview.JoinPressed.anonymous, parameters: nil)
            RoutingManager.auth.routeFrom(controller: self, success: {
                [weak self] in
                if let s = self {
                    s.joinButtonPressed(sender)
                }
            }, cancel: nil)
            return
        } else {
            AnalyticsReporter.reportEvent(AnalyticsEvents.CourseOverview.JoinPressed.signed, parameters: nil)
        }

        //TODO : Add statuses
        if let c = course {

            if !c.enrolled {
                SVProgressHUD.show()
                sender.isEnabled = false
                _ = AuthManager.sharedManager.joinCourseWithId(c.id, success : {
                    [weak self] in
                    SVProgressHUD.showSuccess(withStatus: "")
                    sender.isEnabled = true
                    sender.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
                    self?.course?.enrolled = true
                    CoreDataHelper.instance.save()
                    CoursesJoinManager.sharedManager.addedCourses += [c]
                    WatchDataHelper.parseAndAddPlainCourses(WatchCoursesDisplayingHelper.getCurrentlyDisplayingCourses())
                    self?.performSegue(withIdentifier: "showSections", sender: nil)
                    self?.initBarButtonItems(dropAvailable: c.enrolled)
                    }, error: {
                        status in
                        SVProgressHUD.showError(withStatus: status)
                        sender.isEnabled = true
                })
            } else {
                self.performSegue(withIdentifier: "showSections", sender: nil)
            }
        }
    }

    func askForUnenroll(unenroll: @escaping () -> Void) {
        let alert = UIAlertController(title: NSLocalizedString("UnenrollAlertTitle", comment: ""), message: NSLocalizedString("UnenrollAlertMessage", comment: ""), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Unenroll", comment: ""), style: .destructive, handler: {
            _ in
            unenroll()
        }))

        self.present(alert, animated: true, completion: nil)
    }

    func reloadTableView() {
        var changingIndexPaths: [IndexPath] = []
        for i in 0 ..< max(textData[0].count, textData[1].count) {
            changingIndexPaths += [IndexPath(row: i, section: 0)]
        }
        tableView.reloadRows(at: changingIndexPaths, with: UITableViewRowAnimation.automatic)
    }

    fileprivate func getPlayerHeight() -> CGFloat {
        if course?.introURL == "" && course?.introVideo == nil {
            return 0
        }
        let w = UIScreen.main.bounds.width
        return w * (9 / 16)
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        tableView.reloadData()
        resetHeightConstraints()
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

extension CoursePreviewViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return course == nil ? 0 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            print(max(textData[0].count, textData[1].count, sectionTitles.count, 1))
            return max(textData[0].count, textData[1].count, sectionTitles.count, 1)
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if displayingInfoType == .syllabus {
            if indexPath.row < sectionTitles.count {
                var cell = tableView.dequeueReusableCell(withIdentifier: "SectionTitleTableViewCell")
                if cell == nil {
                    cell = UITableViewCell(style: .default, reuseIdentifier: "SectionTitleTableViewCell")
                }
                cell?.textLabel?.text = "\(indexPath.row + 1). \(sectionTitles[indexPath.row])"
                cell?.textLabel?.numberOfLines = 0
                cell?.textLabel?.textColor = UIColor.mainTextColor
                return cell ?? UITableViewCell()
            } else {
                return UITableViewCell()
            }
        }
        if indexPath.row >= textData[displayingInfoType.rawValue].count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTableViewCell", for: indexPath)
            return cell
        }

        if textData[displayingInfoType.rawValue][indexPath.row].0 == "" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TeachersTableViewCell", for: indexPath) as! TeachersTableViewCell
            cell.initWithCourse(course!)
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTextTableViewCell", for: indexPath) as! TitleTextTableViewCell
        cell.initWith(title: textData[displayingInfoType.rawValue][indexPath.row].0, text: textData[displayingInfoType.rawValue][indexPath.row].1)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralInfoTableViewCell") as! GeneralInfoTableViewCell
//        let cell = GeneralInfoTableViewCell(style: .default, reuseIdentifier: "GeneralInfoTableViewCell")
        cell.initWithCourse(course!)

        cell.typeSegmentedControl.selectedSegmentIndex = displayingInfoType.rawValue
        var cFrame: CGRect
        if let c = course {
            cFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: GeneralInfoTableViewCell.heightForCellWith(c))
        } else {
            cFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 0)
        }
        cell.frame = cFrame
        let cv = UIView()
        cv.addSubview(cell)
        cv.backgroundColor = UIColor.white
        return cv
    }
}

extension CoursePreviewViewController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if displayingInfoType == .syllabus {
            if indexPath.row < sectionTitles.count {
                return UITableViewAutomaticDimension
            } else {
                return 0
            }
        }
        if indexPath.row >= textData[displayingInfoType.rawValue].count {
            return 0
        }
        if textData[displayingInfoType.rawValue][indexPath.row].0 == "" {
            if course?.instructorsArray.count == 0 {
                return 0
            } else {
                return 167
            }
        }
        return heights[displayingInfoType.rawValue][indexPath.row]
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

            if let c = course {
                return GeneralInfoTableViewCell.heightForCellWith(c)
            } else {
                return 0
            }
    }
}

extension CoursePreviewViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView == self.tableView) {
            if (scrollView.contentOffset.y < 0) {
                scrollView.contentOffset = CGPoint.zero
            }
        }
    }
}
