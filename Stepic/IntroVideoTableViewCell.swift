//
//  IntroVideoTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import MediaPlayer

class IntroVideoTableViewCell: UITableViewCell {

    @IBOutlet weak var videoWebView: UIWebView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var thumbnailImageView: UIImageView!

    var video: Video!
    var moviePlayer : MPMoviePlayerController? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        videoWebView.scrollView.scrollEnabled = false
        videoWebView.scrollView.bouncesZoom = false
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
    
    func initWithCourse(course: Course) {
        //        print(course.introURL)
        if let introVideo = course.introVideo {
            setupPlayerWithVideo(introVideo)
        } else {
            loadVimeoURL(NSURL(string: course.introURL)!)
        }
    }
    
    private func setupPlayerWithVideo(video: Video) {
        thumbnailImageView.sd_setImageWithURL(NSURL(string: video.thumbnailURL), placeholderImage: Images.videoPlaceholder)
        
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
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "willExitFullscreen", name: MPMoviePlayerWillExitFullscreenNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "didExitFullscreen", name: MPMoviePlayerDidExitFullscreenNotification, object: nil)
            
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
    
    @IBAction func playButtonPressed(sender: UIButton) {
        if ConnectionHelper.shared.reachability.isReachableViaWiFi() || ConnectionHelper.shared.reachability.isReachableViaWWAN() {
            setControls(playing: true)
            self.moviePlayer?.play()
        }         
    }
    
    
    
}
