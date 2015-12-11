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
    var assignment : Assignment?
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO : Find out the reasons of such behavior!
        
        thumbnailImageView.sd_setImageWithURL(NSURL(string: video.thumbnailURL), placeholderImage: Images.videoPlaceholder)
                
        //        print("URL scheme of the movie -> \(url.scheme)")
        self.moviePlayer = MPMoviePlayerController(contentURL: videoURL)
        if let player = self.moviePlayer {
//            player.view.frame = CGRect(x: 0, y: 44, width: self.view.frame.size.width, height: self.view.frame.size.height - 107)
//            player.view.sizeToFit()
            player.scalingMode = MPMovieScalingMode.AspectFit
            //            player.scalingMode = MPMovieScalingMode.Fill
            player.fullscreen = false
            //               player.controlStyle = MPMovieControlStyle.Embedded
            player.movieSourceType = MPMovieSourceType.File
            player.repeatMode = MPMovieRepeatMode.None
            //               player.play()
            self.view.addSubview(player.view)
//            [[NSNotificationCenter defaultCenter] addObserver:self 
//                selector:@selector(playbackStateChanged) 
//            name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "willExitFullscreen", name: MPMoviePlayerWillExitFullscreenNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "didExitFullscreen", name: MPMoviePlayerDidExitFullscreenNotification, object: nil)

            self.moviePlayer?.view.alignLeading("0", trailing: "0", toView: self.view)
            self.moviePlayer?.view.alignTop("44", bottom: "0", toView: self.view)
            self.moviePlayer?.view.hidden = true
        }
    
                // Do any additional setup after loading the view.
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
        if video.state == VideoState.Cached {
            return try! NSURL(fileURLWithPath: PathManager.sharedManager.getPathForStoredVideoWithName(video.name))
        } else {
            return video.getUrlForQuality(VideosInfo.videoQuality)
        }
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
    
    @IBAction func playButtonPressed(sender: UIButton) {
        setControls(playing: true)
        self.moviePlayer?.play()
    }
    
    var itemView : VideoDownloadView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        itemView = VideoDownloadView(frame: CGRect(x: 0, y: 0, width: 100, height: 30), video: video, buttonDelegate: self, downloadDelegate: self)
        nItem.rightBarButtonItem = UIBarButtonItem(customView: itemView)
        print(self.moviePlayer?.view.frame)

        SVProgressHUD.dismiss()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        if let a = assignment {
            ApiDataDownloader.sharedDownloader.didVisitStepWith(id: step.id, assignment: a.id, success: {}) 
        }
//        thumbnailImageView.hidden = false
//        moviePlayer?.view.hidden = true
//        if let player = self.moviePlayer {
//            if player.playbackState != MPMoviePlaybackState.Playing {
//                player.play()
//            }
//        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        if let player = self.moviePlayer {
            if player.playbackState != MPMoviePlaybackState.Paused && player.fullscreen == false {
                player.pause()
                setControls(playing: false)
            }
        }
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
    func downloadButtonTapped(downloadButton: PKDownloadButton!, currentState state: PKDownloadButtonState) {
        switch downloadButton.state {
        case .StartDownload: 
            
            if !ConnectionHelper.shared.isReachable {
                Messages.sharedManager.show3GDownloadErrorMessage(inController: self.navigationController!)
                print("Not reachable to download")
                return
            }
            
            downloadButton.state = .Downloading
            video.store(video.cachedQuality ?? VideosInfo.videoQuality, progress: {
                prog in
                UIThread.performUI({downloadButton.stopDownloadButton?.progress = CGFloat(prog)})
                }, completion: {
                    completed in
                    if completed {
                        UIThread.performUI({downloadButton.state = .Downloaded})
                    } else {
                        UIThread.performUI({downloadButton.state = .StartDownload})
                    }
                }, error: {
                    error in
                    print("Error while downloading video!!!")
            })
            break
        case .Downloaded:
            if video.removeFromStore() {
                downloadButton.state = .StartDownload
                reload(reloadViews: true)
            } 
            break
        case .Downloading:
            if video.cancelStore() {
                downloadButton.state = .StartDownload
            }
            break
        case .Pending:
            break
        }
        itemView.updateButton()
    }
}

extension VideoStepViewController : VideoDownloadDelegate {
    
    private func askForReload() {
        let alert = UIAlertController(title: NSLocalizedString("ReloadPlayerTitle", comment: ""), message: NSLocalizedString("ReloadPlayerMessage", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: {
            action in
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Reload", comment: ""), style: UIAlertActionStyle.Default, handler: {
            action in
            self.moviePlayer?.pause()
            self.reload(reloadViews: true)
//            self.moviePlayer?.play()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func didDownload(video: Video, cancelled: Bool) {
        if !cancelled { 
            askForReload()
        }
    }
    
    func didGetError(video: Video) {
        itemView.updateButton()
    }
}
