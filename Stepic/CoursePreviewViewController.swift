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

class CoursePreviewViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
            
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var videoWebView: UIWebView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var thumbnailImageView: UIImageView!

    var video: Video!
    var moviePlayer : MPMoviePlayerController? = nil
    
    var course : Course? = nil {
        didSet {
            if let c = course {                
                textData[0] += [("", "")]
                heights[0] += [0]
                if c.summary != "" {
                    textData[0] += [(NSLocalizedString("Summary", comment: ""), c.summary)]
                    heights[0] += [TitleTextTableViewCell.heightForCellWith(title: NSLocalizedString("Summary", comment: ""), text: c.summary)]
                }
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
    
    var displayingInfoType : DisplayingInfoType = .overview 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TitleTextTableViewCell", bundle: nil), forCellReuseIdentifier: "TitleTextTableViewCell")
        
        self.navigationItem.backBarButtonItem?.title = ""
        
        tableView.tableFooterView = UIView()
        
        tableView.estimatedRowHeight = 44.0
        videoWebView.scrollView.isScrollEnabled = false
        videoWebView.scrollView.bouncesZoom = false
        
        let shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(CoursePreviewViewController.shareButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem = shareBarButtonItem
        
        if let c = course {
            sectionTitles = []
            for section in c.sections {
                sectionTitles += [section.title]
            }
            tableView.reloadData()
            resetHeightConstraints()
            if let introVideo = c.introVideo {
                setIntroMode(fromVideo: true)
                setupPlayerWithVideo(introVideo)
            } else {
                setIntroMode(fromVideo: false)
                loadVimeoURL(NSURL(string: c.introURL) as! URL)
            }
            updateSections()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    func shareButtonPressed(_ button: UIBarButtonItem) {
    
        AnalyticsReporter.reportEvent(AnalyticsEvents.CourseOverview.shared, parameters: nil)
        
        if let slug = course?.slug {
            DispatchQueue.global( priority: DispatchQueue.GlobalQueuePriority.default).async {
                let shareVC = SharingHelper.getSharingController(StepicApplicationsInfo.stepicURL + "/course/" + slug + "/")
                shareVC.popoverPresentationController?.barButtonItem = button
                DispatchQueue.main.async {
                    self.present(shareVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    fileprivate func updateSections() {
        if let c = course {
            let successBlock = {
                [weak self] in
                self?.sectionTitles = []
                for section in c.sections {
                    self?.sectionTitles += [section.title]
                }
                self?.isErrorWhileLoadingSections = false
                self?.isLoadingSections = false
                UIThread.performUI{ self?.tableView.reloadData() }
            }
        
            let errorBlock = {
                [weak self] in
                self?.isErrorWhileLoadingSections = true
                self?.isLoadingSections = false
                UIThread.performUI{ self?.tableView.reloadData() }
            }
        
            isLoadingSections = true
            if AuthInfo.shared.isAuthorized {
                c.loadAllSections(success: successBlock, error: errorBlock, withProgresses: false)
            } else {
                c.loadSectionsWithoutAuth(success: successBlock, error: errorBlock)
            }
        }
    }
    
    var sectionTitles = [String]()
    var isErrorWhileLoadingSections : Bool = false
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
    
    fileprivate func loadVimeoURL(_ url: URL) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            self.videoWebView.loadRequest(URLRequest(url: url))
        }
    }
    
    fileprivate func setIntroMode(fromVideo: Bool) {
        videoWebView.isHidden = fromVideo
        playButton.isHidden = !fromVideo
        thumbnailImageView.isHidden = !fromVideo
    }
    
    var imageTapHelper : ImageTapHelper!
    
    fileprivate func setupPlayerWithVideo(_ video: Video) {
        thumbnailImageView.sd_setImage(with: URL(string: video.thumbnailURL), placeholderImage: Images.videoPlaceholder)
        
        imageTapHelper = ImageTapHelper(imageView: thumbnailImageView, action: {
            [weak self]
            recognizer in
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
            
            self.moviePlayer?.view.alignLeading("0", trailing: "0", to: self.contentView)
            self.moviePlayer?.view.alignTop("0", bottom: "0", to: self.contentView)
            self.moviePlayer?.view.isHidden = true
        }
    }
    
    var fullScreenWasPlaying : Bool = false
    
    func didExitFullscreen() {
        if fullScreenWasPlaying {
            self.moviePlayer?.play()
        }
    }
    
    func willExitFullscreen() {
        fullScreenWasPlaying = self.moviePlayer?.playbackState == MPMoviePlaybackState.playing
    }
    
    var videoURL : URL {
        return video.getUrlForQuality(VideosInfo.videoQuality)
    }
    
    func reload(reloadViews rv: Bool) {
        
        self.moviePlayer?.movieSourceType = MPMovieSourceType.file
        self.moviePlayer?.contentURL = videoURL
        
        if rv {
            setControls(playing: false)
        }
    }
    
    var isShowingPlayer : Bool {
        return !(self.moviePlayer?.view.isHidden ?? true)
    }
    
    func setControls(playing p : Bool) {
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
    
    fileprivate var textData : [[(String, String)]] = [
        //Overview
        [],
        //Detailed
        []
    ]
    
    fileprivate var heights : [[CGFloat]] = [
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
            if let vc = ControllerHelper.getAuthController() as? AuthNavigationViewController {
                vc.success = {
                    [weak self] in
                    if let s = self {
                        s.joinButtonPressed(sender)
                    }
                }
                self.present(vc, animated: true, completion: nil)
            }
            return
        }
        
        //TODO : Add statuses
        if let c = course {
            
            if sender.isEnabledToJoin {
                SVProgressHUD.show()
                AuthManager.sharedManager.joinCourseWithId(c.id, success : {
                    SVProgressHUD.showSuccess(withStatus: "")
                    sender.setDisabledJoined()
                    self.course?.enrolled = true
                    CoreDataHelper.instance.save()
                    CoursesJoinManager.sharedManager.addedCourses += [c]
                    self.performSegue(withIdentifier: "showSections", sender: nil)
                    }, error:  {
                        status in
                        SVProgressHUD.showError(withStatus: status)
                }) 
            } else {
                askForUnenroll(unenroll: {
                    SVProgressHUD.show()
                    AuthManager.sharedManager.joinCourseWithId(c.id, delete: true, success : {
                        SVProgressHUD.showSuccess(withStatus: "")
                        sender.setEnabledJoined()
                        self.course?.enrolled = false
                        CoreDataHelper.instance.save()
                        CoursesJoinManager.sharedManager.deletedCourses += [c]
                        self.navigationController?.popToRootViewController(animated: true)
                        }, error:  {
                            status in
                            SVProgressHUD.showError(withStatus: status)
                    })
                })
            }
        }
    }
    
    func askForUnenroll(unenroll: @escaping (Void)->Void) {
        let alert = UIAlertController(title: NSLocalizedString("UnenrollAlertTitle", comment: "") , message: NSLocalizedString("UnenrollAlertMessage", comment: ""), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Unenroll", comment: "") , style: .destructive, handler: {
            action in
            unenroll()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func reloadTableView() {
        var changingIndexPaths : [IndexPath] = []
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
    
}

extension CoursePreviewViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return course == nil ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return max(textData[0].count, textData[1].count, sectionTitles.count, 1)
        default: 
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if displayingInfoType == .syllabus {
            if (indexPath as NSIndexPath).row < sectionTitles.count {
                var cell = tableView.dequeueReusableCell(withIdentifier: "SectionTitleTableViewCell") 
                if cell == nil {
                    cell = UITableViewCell(style: .default, reuseIdentifier: "SectionTitleTableViewCell")
                }
                cell?.textLabel?.text = "\((indexPath as NSIndexPath).row + 1). \(sectionTitles[(indexPath as NSIndexPath).row])"
                cell?.textLabel?.numberOfLines = 0
                return cell ?? UITableViewCell()
            } else {
                return UITableViewCell()
            }
        }
        if (indexPath as NSIndexPath).row >= textData[displayingInfoType.rawValue].count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTableViewCell", for: indexPath)
            return cell
        }
        
        if textData[displayingInfoType.rawValue][(indexPath as NSIndexPath).row].0 == "" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TeachersTableViewCell", for: indexPath) as! TeachersTableViewCell
            cell.initWithCourse(course!)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTextTableViewCell", for: indexPath) as! TitleTextTableViewCell
        cell.initWith(title: textData[displayingInfoType.rawValue][(indexPath as NSIndexPath).row].0, text: textData[displayingInfoType.rawValue][(indexPath as NSIndexPath).row].1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralInfoTableViewCell") as! GeneralInfoTableViewCell
        cell.initWithCourse(course!)
        
        cell.typeSegmentedControl.selectedSegmentIndex = displayingInfoType.rawValue
        var cFrame : CGRect
        if let c = course {
            cFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: GeneralInfoTableViewCell.heightForCellWith(c))
        } else {
            cFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 0)
        }
        cell.frame = cFrame
        let cv = UIView()
        cv.addSubview(cell)
        
        return cv
    }
}

extension CoursePreviewViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if displayingInfoType == .syllabus {
            if (indexPath as NSIndexPath).row < sectionTitles.count {
                return UITableViewAutomaticDimension
            } else {
                return 0
            }
        }
        if (indexPath as NSIndexPath).row >= textData[displayingInfoType.rawValue].count {
            return 0
        }
        if textData[displayingInfoType.rawValue][(indexPath as NSIndexPath).row].0 == "" {
            return 137
        }
        return heights[displayingInfoType.rawValue][(indexPath as NSIndexPath).row]
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
