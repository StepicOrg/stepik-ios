//
//  VideoStepViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import MediaPlayer
import SVProgressHUD
import DownloadButton
import FLKAutoLayout

class VideoStepViewController: UIViewController {
    
    var moviePlayer : MPMoviePlayerController? = nil
    var video : Video!
    var nItem : UINavigationItem!
    var step: Step!
    var stepId : Int!
    var lessonSlug: String!
    
    var startStepId: Int!
    var startStepBlock : ((Void)->Void)!
    var shouldSendViewsBlock : ((Void)->Bool)!

    var assignment : Assignment?
    
    var parentNavigationController : UINavigationController?
    
    var nextLessonHandler: ((Void)->Void)?
    var prevLessonHandler: ((Void)->Void)?
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    @IBOutlet weak var discussionCountView: DiscussionCountView!
    @IBOutlet weak var discussionCountViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var prevLessonButton: UIButton!
    @IBOutlet weak var nextLessonButton: UIButton!
    @IBOutlet weak var nextLessonButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var prevLessonButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var prevNextLessonButtonsContainerViewHeight: NSLayoutConstraint!
    
    
//    @IBOutlet weak var discussionToPrevDistance: NSLayoutConstraint!
//    @IBOutlet weak var discussionToNextDistance: NSLayoutConstraint!
//    @IBOutlet weak var prevToBottomDistance: NSLayoutConstraint!
//    @IBOutlet weak var nextToBottomDistance: NSLayoutConstraint!
    
    var imageTapHelper : ImageTapHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoStepViewController.updatedStepNotification(_:)), name: NSNotification.Name(rawValue: StepsViewController.stepUpdatedNotification), object: nil)
        
        imageTapHelper = ImageTapHelper(imageView: thumbnailImageView, action: { 
            [weak self]
            recognizer in
            self?.playVideo()
            })
        
        nextLessonButton.setTitle("  \(NSLocalizedString("NextLesson", comment: ""))  ", for: UIControlState())
        prevLessonButton.setTitle("  \(NSLocalizedString("PrevLesson", comment: ""))  ", for: UIControlState())
        
        initialize()
    }
    
    func sharePressed(_ item: UIBarButtonItem) {
//        AnalyticsReporter.reportEvent(AnalyticsEvents.Syllabus.shared, parameters: nil)
        
        guard let slug = lessonSlug, let stepid = stepId else {
            return
        }
        DispatchQueue.global( priority: DispatchQueue.GlobalQueuePriority.default).async {
            let shareVC = SharingHelper.getSharingController(StepicApplicationsInfo.stepicURL + "/lesson/" + slug + "/step/" + "\(stepid)")
            shareVC.popoverPresentationController?.barButtonItem = item
            DispatchQueue.main.async {
                self.present(shareVC, animated: true, completion: nil)
            }
        }
    }
    
    func initialize() {
        thumbnailImageView.sd_setImage(with: URL(string: video.thumbnailURL), placeholderImage: Images.videoPlaceholder)
        
        if let discussionCount = step.discussionsCount {
            discussionCountView.commentsCount = discussionCount
            discussionCountView.showCommentsHandler = {
                [weak self] in
                self?.showComments()
            }
        } else {
            discussionCountViewHeight.constant = 0
        }
        
        if nextLessonHandler == nil {
            nextLessonButton.isHidden = true
        } else {
            nextLessonButton.setStepicWhiteStyle()
        }
        
        if prevLessonHandler == nil {
            prevLessonButton.isHidden = true
        } else {
            prevLessonButton.setStepicWhiteStyle()
        }
        
        if nextLessonHandler == nil && prevLessonHandler == nil {
            nextLessonButtonHeight.constant = 0
            prevLessonButtonHeight.constant = 0
            prevNextLessonButtonsContainerViewHeight.constant = 0
//            discussionToNextDistance.constant = 0
//            discussionToPrevDistance.constant = 0
//            prevToBottomDistance.constant = 0
//            nextToBottomDistance.constant = 0
        }
    }
    
    func updatedStepNotification(_ notification: Foundation.Notification) {
        initialize()
    }
    
    fileprivate func presentNoVideoAlert() {
        let alert = UIAlertController(title: NSLocalizedString("NoVideo", comment: ""), message: NSLocalizedString("AuthorDidntUploadVideo", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func playVideo() {
        
        if video.urls.count == 0 {
            presentNoVideoAlert()
            return
        }
        
        if video.state == VideoState.cached || (ConnectionHelper.shared.reachability.isReachableViaWiFi() || ConnectionHelper.shared.reachability.isReachableViaWWAN()) {
            let player = StepicVideoPlayerViewController(nibName: "StepicVideoPlayerViewController", bundle: nil)
            player.video = self.video
            self.present(player, animated: true, completion: {
                print("stepic player successfully presented!")
            })
        } else {
            if let vc = self.parentNavigationController {
                Messages.sharedManager.showConnectionErrorMessage(inController: vc)
            }
        }
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        playVideo()
    }
    
    var itemView : VideoDownloadView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        itemView = VideoDownloadView(frame: CGRect(x: 0, y: 0, width: 100, height: 30), video: video, buttonDelegate: self, downloadDelegate: self)
        let shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(VideoStepViewController.sharePressed(_:)))
        nItem.rightBarButtonItems = [shareBarButtonItem, UIBarButtonItem(customView: itemView)]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let cstep = step else {
            return
        }
        
        AnalyticsReporter.reportEvent(AnalyticsEvents.Step.opened, parameters: ["item_name": step.block.name as NSObject])

        let stepid = step.id         
        if stepId - 1 == startStepId {
            startStepBlock()
        }
        if shouldSendViewsBlock() {
            performRequest({
                [weak self] in
                print("Sending view for step with id \(stepid) & assignment \(self?.assignment?.id)")
                _ = ApiDataDownloader.views.create(stepId: stepid, assignment: self?.assignment?.id, success: {
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: StepDoneNotificationKey), object: nil, userInfo: ["id" : cstep.id])
                    UIThread.performUI{
                        cstep.progress?.isPassed = true
                        CoreDataHelper.instance.save()
                    }
                }) 
            })
        }
    }
    
    @IBAction func showCommentsPressed(_ sender: AnyObject) {
        showComments()
    }
    
    func showComments() {
        if let discussionProxyId = step.discussionProxyId {
            let vc = DiscussionsViewController(nibName: "DiscussionsViewController", bundle: nil) 
            vc.discussionProxyId = discussionProxyId
            vc.target = self.step.id
            navigationController?.pushViewController(vc, animated: true)
        } else {
            //TODO: Load comments here
        }
    }
    
    @IBAction func prevLessonPressed(_ sender: UIButton) {
        prevLessonHandler?()
    }
    
    @IBAction func nextLessonPressed(_ sender: UIButton) {
        nextLessonHandler?()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

extension VideoStepViewController : PKDownloadButtonDelegate {
    func downloadButtonTapped(_ downloadButton: PKDownloadButton!, currentState state: PKDownloadButtonState) {
        
        if video.urls.count == 0 {
            presentNoVideoAlert()
            return
        }
        
        switch downloadButton.state {
        case .startDownload: 
            
            if !ConnectionHelper.shared.isReachable {
                Messages.sharedManager.show3GDownloadErrorMessage(inController: self.navigationController!)
                print("Not reachable to download")
                return
            }
            
            downloadButton.state = .downloading
            video.store(VideosInfo.downloadingVideoQuality, progress: {
                prog in
                UIThread.performUI({downloadButton.stopDownloadButton?.progress = CGFloat(prog)})
                }, completion: {
                    completed in
                    if completed {
                        UIThread.performUI({downloadButton.state = .downloaded})
                    } else {
                        UIThread.performUI({downloadButton.state = .startDownload})
                    }
                }, error: {
                    error in
                    print("Error while downloading video!!!")
            })
            break
        case .downloaded:
            if video.removeFromStore() {
                downloadButton.state = .startDownload
            } 
            break
        case .downloading:
            if video.cancelStore() {
                downloadButton.state = .startDownload
            }
            break
        case .pending:
            break
        }
        itemView.updateButton()
    }
}

extension VideoStepViewController : VideoDownloadDelegate {
    
    func didDownload(_ video: Video, cancelled: Bool) {
    }
    
    func didGetError(_ video: Video) {
        itemView.updateButton()
    }
}
