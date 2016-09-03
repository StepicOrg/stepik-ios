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
    
    var displayingInfoType : DisplayingInfoType = .Overview 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "TitleTextTableViewCell", bundle: nil), forCellReuseIdentifier: "TitleTextTableViewCell")
        
        self.navigationItem.backBarButtonItem?.title = ""
        
        tableView.tableFooterView = UIView()
        
        tableView.estimatedRowHeight = 44.0
        videoWebView.scrollView.scrollEnabled = false
        videoWebView.scrollView.bouncesZoom = false
        
        let shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: #selector(CoursePreviewViewController.shareButtonPressed(_:)))
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
                loadVimeoURL(NSURL(string: c.introURL)!)
            }
            updateSections()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    func shareButtonPressed(button: UIBarButtonItem) {
    
        AnalyticsReporter.reportEvent(AnalyticsEvents.CourseOverview.shared, parameters: nil)
        
        if let slug = course?.slug {
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let shareVC = SharingHelper.getSharingController(StepicApplicationsInfo.stepicURL + "/course/" + slug + "/")
                shareVC.popoverPresentationController?.barButtonItem = button
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(shareVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func updateSections() {
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
    
    private func resetHeightConstraints() {
        let v = self.tableView.tableHeaderView
        var headerframe = v?.frame
        headerframe?.size.height = getPlayerHeight()
        v?.frame = headerframe ?? CGRectZero
        tableView.tableHeaderView = v
        
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.setNeedsUpdateConstraints()
        tableView.updateConstraintsIfNeeded()
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    private func loadVimeoURL(url: NSURL) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.videoWebView.loadRequest(NSURLRequest(URL: url))
        }
    }
    
    private func setIntroMode(fromVideo fromVideo: Bool) {
        videoWebView.hidden = fromVideo
        playButton.hidden = !fromVideo
        thumbnailImageView.hidden = !fromVideo
    }
    
    var imageTapHelper : ImageTapHelper!
    
    private func setupPlayerWithVideo(video: Video) {
        thumbnailImageView.sd_setImageWithURL(NSURL(string: video.thumbnailURL), placeholderImage: Images.videoPlaceholder)
        
        imageTapHelper = ImageTapHelper(imageView: thumbnailImageView, action: {
            [weak self]
            recognizer in
            self?.playVideo()
        })
        
        self.video = video
        
        if video.urls.count == 0 {
            videoWebView.hidden = true
            playButton.hidden = true
            thumbnailImageView.hidden = false
            return
        }
        
        self.moviePlayer = MPMoviePlayerController(contentURL: videoURL)
        if let player = self.moviePlayer {
            player.scalingMode = MPMovieScalingMode.AspectFit
            player.fullscreen = false
            player.movieSourceType = MPMovieSourceType.File
            player.repeatMode = MPMovieRepeatMode.None
            self.contentView.addSubview(player.view)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CoursePreviewViewController.willExitFullscreen), name: MPMoviePlayerWillExitFullscreenNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CoursePreviewViewController.didExitFullscreen), name: MPMoviePlayerDidExitFullscreenNotification, object: nil)
            
            self.moviePlayer?.view.alignLeading("0", trailing: "0", toView: self.contentView)
            self.moviePlayer?.view.alignTop("0", bottom: "0", toView: self.contentView)
            self.moviePlayer?.view.hidden = true
        }
    }
    
    var fullScreenWasPlaying : Bool = false
    
    func didExitFullscreen() {
        if fullScreenWasPlaying {
            self.moviePlayer?.play()
        }
    }
    
    func willExitFullscreen() {
        fullScreenWasPlaying = self.moviePlayer?.playbackState == MPMoviePlaybackState.Playing
    }
    
    var videoURL : NSURL {
        return video.getUrlForQuality(VideosInfo.videoQuality)
    }
    
    func reload(reloadViews rv: Bool) {
        
        self.moviePlayer?.movieSourceType = MPMovieSourceType.File
        self.moviePlayer?.contentURL = videoURL
        
        if rv {
            setControls(playing: false)
        }
    }
    
    var isShowingPlayer : Bool {
        return !(self.moviePlayer?.view.hidden ?? true)
    }
    
    func setControls(playing p : Bool) {
        self.moviePlayer?.view.hidden = !p
        self.thumbnailImageView.hidden = p
        self.playButton.hidden = p
    }
    
    func playVideo() {
        if ConnectionHelper.shared.reachability.isReachableViaWiFi() || ConnectionHelper.shared.reachability.isReachableViaWWAN() {
            setControls(playing: true)
            self.moviePlayer?.play()
        }   
    }
    
    @IBAction func playButtonPressed(sender: UIButton) {
        playVideo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private var textData : [[(String, String)]] = [
        //Overview
        [],
        //Detailed
        []
    ]
    
    private var heights : [[CGFloat]] = [
        //Overview
        [],
        //Detailed
        []
    ]
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSections" {
            let dvc = segue.destinationViewController as! SectionsViewController
            dvc.course = course
        }
    }
    
    @IBAction func displayingSegmentedControlValueChanged(sender: UISegmentedControl) {
        displayingInfoType = DisplayingInfoType(rawValue: sender.selectedSegmentIndex) ?? .Overview
        reloadTableView()
    }
    
    
    @IBAction func joinButtonPressed(sender: UIButton) {
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
                self.presentViewController(vc, animated: true, completion: nil)
            }
            return
        }
        
        //TODO : Add statuses
        if let c = course {
            
            if sender.isEnabledToJoin {
                SVProgressHUD.show()
                AuthManager.sharedManager.joinCourseWithId(c.id, success : {
                    SVProgressHUD.showSuccessWithStatus("")
                    sender.setDisabledJoined()
                    self.course?.enrolled = true
                    CoreDataHelper.instance.save()
                    CoursesJoinManager.sharedManager.addedCourses += [c]
                    self.performSegueWithIdentifier("showSections", sender: nil)
                    }, error:  {
                        status in
                        SVProgressHUD.showErrorWithStatus(status)
                }) 
            } else {
                askForUnenroll(unenroll: {
                    SVProgressHUD.show()
                    AuthManager.sharedManager.joinCourseWithId(c.id, delete: true, success : {
                        SVProgressHUD.showSuccessWithStatus("")
                        sender.setEnabledJoined()
                        self.course?.enrolled = false
                        CoreDataHelper.instance.save()
                        CoursesJoinManager.sharedManager.deletedCourses += [c]
                        self.navigationController?.popToRootViewControllerAnimated(true)
                        }, error:  {
                            status in
                            SVProgressHUD.showErrorWithStatus(status)
                    })
                })
            }
        }
    }
    
    func askForUnenroll(unenroll unenroll: Void->Void) {
        let alert = UIAlertController(title: NSLocalizedString("UnenrollAlertTitle", comment: "") , message: NSLocalizedString("UnenrollAlertMessage", comment: ""), preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Unenroll", comment: "") , style: .Destructive, handler: {
            action in
            unenroll()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func reloadTableView() {
        var changingIndexPaths : [NSIndexPath] = []
        for i in 0 ..< max(textData[0].count, textData[1].count) {
            changingIndexPaths += [NSIndexPath(forRow: i, inSection: 0)]
        }
        tableView.reloadRowsAtIndexPaths(changingIndexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    private func getPlayerHeight() -> CGFloat {
        if course?.introURL == "" && course?.introVideo == nil {
            return 0
        }
        let w = UIScreen.mainScreen().bounds.width
        return w * (9 / 16)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        tableView.reloadData()
        resetHeightConstraints()
    }
    
}

extension CoursePreviewViewController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return course == nil ? 0 : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return max(textData[0].count, textData[1].count, sectionTitles.count, 1)
        default: 
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if displayingInfoType == .Syllabus {
            if indexPath.row < sectionTitles.count {
                var cell = tableView.dequeueReusableCellWithIdentifier("SectionTitleTableViewCell") 
                if cell == nil {
                    cell = UITableViewCell(style: .Default, reuseIdentifier: "SectionTitleTableViewCell")
                }
                cell?.textLabel?.text = "\(indexPath.row + 1). \(sectionTitles[indexPath.row])"
                cell?.textLabel?.numberOfLines = 0
                return cell ?? UITableViewCell()
            } else {
                return UITableViewCell()
            }
        }
        if indexPath.row >= textData[displayingInfoType.rawValue].count {
            let cell = tableView.dequeueReusableCellWithIdentifier("DefaultTableViewCell", forIndexPath: indexPath)
            return cell
        }
        
        if textData[displayingInfoType.rawValue][indexPath.row].0 == "" {
            let cell = tableView.dequeueReusableCellWithIdentifier("TeachersTableViewCell", forIndexPath: indexPath) as! TeachersTableViewCell
            cell.initWithCourse(course!)
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TitleTextTableViewCell", forIndexPath: indexPath) as! TitleTextTableViewCell
        cell.initWith(title: textData[displayingInfoType.rawValue][indexPath.row].0, text: textData[displayingInfoType.rawValue][indexPath.row].1)
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("GeneralInfoTableViewCell") as! GeneralInfoTableViewCell
        cell.initWithCourse(course!)
        
        cell.typeSegmentedControl.selectedSegmentIndex = displayingInfoType.rawValue
        var cFrame : CGRect
        if let c = course {
            cFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: GeneralInfoTableViewCell.heightForCellWith(c))
        } else {
            cFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 0)
        }
        cell.frame = cFrame
        let cv = UIView()
        cv.addSubview(cell)
        
        return cv
    }
}

extension CoursePreviewViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if displayingInfoType == .Syllabus {
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
            return 137
        }
        return heights[displayingInfoType.rawValue][indexPath.row]
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

            if let c = course {
                return GeneralInfoTableViewCell.heightForCellWith(c)
            } else {
                return 0
            }
    }
}

extension CoursePreviewViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView == self.tableView) {
            if (scrollView.contentOffset.y < 0) {
                scrollView.contentOffset = CGPointZero
            }
        }
    }
}