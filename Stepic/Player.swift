//  Player.swift
//
//  Created by patrick piemonte on 11/26/14.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014-present patrick piemonte (http://patrickpiemonte.com/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import Foundation
import AVFoundation
import CoreGraphics

public enum PlaybackState: Int, CustomStringConvertible {
    case stopped = 0
    case playing
    case paused
    case failed
    
    public var description: String {
        get {
            switch self {
            case .stopped:
                return "Stopped"
            case .playing:
                return "Playing"
            case .failed:
                return "Failed"
            case .paused:
                return "Paused"
            }
        }
    }
}

public enum BufferingState: Int, CustomStringConvertible {
    case unknown = 0
    case ready
    case delayed
    
    public var description: String {
        get {
            switch self {
            case .unknown:
                return "Unknown"
            case .ready:
                return "Ready"
            case .delayed:
                return "Delayed"
            }
        }
    }
}

public protocol PlayerDelegate: class {
    func playerReady(_ player: Player)
    func playerPlaybackStateDidChange(_ player: Player)
    func playerBufferingStateDidChange(_ player: Player)
    
    func playerPlaybackWillStartFromBeginning(_ player: Player)
    func playerPlaybackDidEnd(_ player: Player)
}

// KVO contexts

private var PlayerObserverContext = 0
private var PlayerItemObserverContext = 0
private var PlayerLayerObserverContext = 0

// KVO player keys

private let PlayerTracksKey = "tracks"
private let PlayerPlayableKey = "playable"
private let PlayerDurationKey = "duration"
private let PlayerRateKey = "rate"

// KVO player item keys

private let PlayerStatusKey = "status"
private let PlayerEmptyBufferKey = "playbackBufferEmpty"
private let PlayerKeepUp = "playbackLikelyToKeepUp"

// KVO player layer keys

private let PlayerReadyForDisplay = "readyForDisplay"

// MARK: - Player

open class Player: UIViewController {
    
    open weak var delegate: PlayerDelegate!
    
    open func setUrl(_ url: URL) {
        // Make sure everything is reset beforehand
        if(self.playbackState == .playing){
            self.pause()
        }
        
        self.setupPlayerItem(nil)
        let asset = AVURLAsset(url: url, options: .none)
        self.setupAsset(asset)
    }
    
    
    open var muted: Bool! {
        get {
            return self.player.isMuted
        }
        set {
            self.player.isMuted = newValue
        }
    }
    
    open var fillMode: String! {
        get {
            return self.playerView.fillMode
        }
        set {
            self.playerView.fillMode = newValue
        }
    }
    
    open var playbackLoops: Bool! {
        get {
            return (self.player.actionAtItemEnd == .none) as Bool
        }
        set {
            if newValue {
                self.player.actionAtItemEnd = .none
            } else {
                self.player.actionAtItemEnd = .pause
            }
        }
    }
    open var playbackFreezesAtEnd: Bool!
    open var playbackState: PlaybackState!
    open var bufferingState: BufferingState!
    
    open var maximumDuration: TimeInterval! {
        get {
            if let playerItem = self.playerItem {
                return CMTimeGetSeconds(playerItem.duration)
            } else {
                return CMTimeGetSeconds(kCMTimeIndefinite)
            }
        }
    }
    
    open var currentTime: TimeInterval! {
        get {
            if let playerItem = self.playerItem {
                return CMTimeGetSeconds(playerItem.currentTime())
            } else {
                return CMTimeGetSeconds(kCMTimeIndefinite)
            }
        }
    }
   
    fileprivate var periodicTimeObserver : AnyObject?
    
    fileprivate func getTimeFromBufferSize() {
        
    }
    
    //block's parameters are current current time + current buffered value 
    open func setPeriodicTimeObserver(_ block: @escaping (TimeInterval, TimeInterval?)->Void) {
        let interval = CMTimeMakeWithSeconds(1, 10)
//        let interval = CMTimeMakeWithSeconds(period, Int32(NSEC_PER_SEC))
        periodicTimeObserver = self.player.addPeriodicTimeObserver(forInterval: interval, queue: nil, using: {
            [weak self]
            time in
            let nTime = CMTimeGetSeconds(time)
            if let item = self?.playerItem {
                if item.loadedTimeRanges.count > 0 {
                    let aTimeRange = item.loadedTimeRanges[0].timeRangeValue
                    let startTime = CMTimeGetSeconds(aTimeRange.start)
                    let loadedDuration = CMTimeGetSeconds(aTimeRange.duration)
                    block(nTime, startTime + loadedDuration)
                } else {
                    print("ALERT loadedTimeTanges count < 0")
                    block(nTime, nil)
                }
                
            }
            
        }) as AnyObject?
    }
    
    fileprivate var asset: AVAsset!
    fileprivate var playerItem: AVPlayerItem?
    
    fileprivate var player: AVPlayer!
    fileprivate var playerView: PlayerView!
    
    // MARK: object lifecycle
    
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
        self.player = AVPlayer()
        self.player.actionAtItemEnd = .pause
        self.player.addObserver(self, forKeyPath: PlayerRateKey, options: ([NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old]) , context: &PlayerObserverContext)
        
        self.playbackLoops = false
        self.playbackFreezesAtEnd = false
        self.playbackState = .stopped
        self.bufferingState = .unknown
    }
    
    deinit {
        if let obs = periodicTimeObserver {
            self.player.removeTimeObserver(obs)
        }
        
        self.playerView?.player = nil
        self.delegate = nil
        
        NotificationCenter.default.removeObserver(self)
        
        self.playerView?.layer.removeObserver(self, forKeyPath: PlayerReadyForDisplay, context: &PlayerLayerObserverContext)
        
        self.player.removeObserver(self, forKeyPath: PlayerRateKey, context: &PlayerObserverContext)
        
        self.player.pause()
        
        self.setupPlayerItem(nil)
        print("player is deinitialized")
    }
    
    // MARK: view lifecycle
    
    open override func loadView() {
        self.playerView = PlayerView(frame: CGRect.zero)
        self.playerView.fillMode = AVLayerVideoGravityResizeAspect
        self.playerView.playerLayer.isHidden = true
        self.view = self.playerView
        self.playerView.layer.addObserver(self, forKeyPath: PlayerReadyForDisplay, options: ([NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old]), context: &PlayerLayerObserverContext)
        
        NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationWillResignActive(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: UIApplication.shared)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.playbackState == .playing {
            self.pause()
        }
    }
    
    // MARK: methods
    
    open func playFromBeginning() {
        self.delegate?.playerPlaybackWillStartFromBeginning(self)
        self.player.seek(to: kCMTimeZero)
        self.playFromCurrentTime()
    }
    
    open func playFromCurrentTime() {
        self.playbackState = .playing
        self.delegate?.playerPlaybackStateDidChange(self)
        self.player.play()
        self.player.rate = rate
    }
    
    open func pause() {
        if self.playbackState != .playing {
            return
        }
        
        self.player.pause()
        self.playbackState = .paused
        self.delegate?.playerPlaybackStateDidChange(self)
    }
    
    open func stop() {
        if self.playbackState == .stopped {
            return
        }
        
        self.player.pause()
        self.playbackState = .stopped
        self.delegate?.playerPlaybackStateDidChange(self)
        self.delegate?.playerPlaybackDidEnd(self)
    }
    
    var rate : Float = 1 {
        didSet {
            if self.player.rate != 0 {
                self.player.rate = rate
            }
        }
    }
    
    open func seekToTime(_ time: CMTime) {
        if let playerItem = self.playerItem {
            return playerItem.seek(to: time)
        }
    }
    
    // MARK: private setup
    
    fileprivate func setupAsset(_ asset: AVAsset) {
        if self.playbackState == .playing {
            self.pause()
        }
        
        self.bufferingState = .unknown
        self.delegate?.playerBufferingStateDidChange(self)
        
        self.asset = asset
        if let _ = self.asset {
            self.setupPlayerItem(nil)
        }
        
        let keys: [String] = [PlayerTracksKey, PlayerPlayableKey, PlayerDurationKey]
        
        self.asset.loadValuesAsynchronously(forKeys: keys, completionHandler: { () -> Void in
            DispatchQueue.main.sync(execute: { () -> Void in
                
                for key in keys {
                    var error: NSError?
                    let status = self.asset.statusOfValue(forKey: key, error:&error)
                    if status == .failed {
                        self.playbackState = .failed
                        self.delegate?.playerPlaybackStateDidChange(self)
                        return
                    }
                }
                
                if self.asset.isPlayable == false {
                    self.playbackState = .failed
                    self.delegate?.playerPlaybackStateDidChange(self)
                    return
                }
                
                let playerItem: AVPlayerItem = AVPlayerItem(asset:self.asset)
                self.setupPlayerItem(playerItem)
                
            })
        })
    }
    
    fileprivate func setupPlayerItem(_ playerItem: AVPlayerItem?) {
        if self.playerItem != nil {
            self.playerItem?.removeObserver(self, forKeyPath: PlayerEmptyBufferKey, context: &PlayerItemObserverContext)
            self.playerItem?.removeObserver(self, forKeyPath: PlayerKeepUp, context: &PlayerItemObserverContext)
            self.playerItem?.removeObserver(self, forKeyPath: PlayerStatusKey, context: &PlayerItemObserverContext)
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: self.playerItem)
        }
        
        self.playerItem = playerItem
        
        if self.playerItem != nil {
            self.playerItem?.addObserver(self, forKeyPath: PlayerEmptyBufferKey, options: ([NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old]), context: &PlayerItemObserverContext)
            self.playerItem?.addObserver(self, forKeyPath: PlayerKeepUp, options: ([NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old]), context: &PlayerItemObserverContext)
            self.playerItem?.addObserver(self, forKeyPath: PlayerStatusKey, options: ([NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old]), context: &PlayerItemObserverContext)
            
            NotificationCenter.default.addObserver(self, selector: #selector(Player.playerItemDidPlayToEndTime(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(Player.playerItemFailedToPlayToEndTime(_:)), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: self.playerItem)
        }
        
        self.player.replaceCurrentItem(with: self.playerItem)
        
        if self.playbackLoops == true {
            self.player.actionAtItemEnd = .none
        } else {
            self.player.actionAtItemEnd = .pause
        }
    }
    
    // MARK: NSNotifications
    
    open func playerItemDidPlayToEndTime(_ aNotification: Foundation.Notification) {
        if self.playbackLoops == true || self.playbackFreezesAtEnd == true {
            self.player.seek(to: kCMTimeZero)
        }
        
        if self.playbackLoops == false {
            self.stop()
        }
    }
    
    open func playerItemFailedToPlayToEndTime(_ aNotification: Foundation.Notification) {
        self.playbackState = .failed
        self.delegate?.playerPlaybackStateDidChange(self)
    }
    
    open func applicationWillResignActive(_ aNotification: Foundation.Notification) {
        if self.playbackState == .playing {
            self.pause()
        }
    }
    
    open func applicationDidEnterBackground(_ aNotification: Foundation.Notification) {
        if self.playbackState == .playing {
            self.pause()
        }
    }
    
    // MARK: KVO
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        switch (keyPath, context) {
        case (.some(PlayerRateKey), PlayerObserverContext):
            true
        case (.some(PlayerStatusKey), PlayerItemObserverContext):
            true
        case (.some(PlayerKeepUp), PlayerItemObserverContext):
            if let item = self.playerItem {
                self.bufferingState = .ready
                self.delegate?.playerBufferingStateDidChange(self)
                
                if item.isPlaybackLikelyToKeepUp && self.playbackState == .playing {
                    self.playFromCurrentTime()
                }
            }
            
            let status = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).intValue as AVPlayerStatus.RawValue
            
            switch (status) {
            case AVPlayerStatus.readyToPlay.rawValue:
                self.playerView.playerLayer.player = self.player
                self.playerView.playerLayer.isHidden = false
            case AVPlayerStatus.failed.rawValue:
                self.playbackState = PlaybackState.failed
                self.delegate?.playerPlaybackStateDidChange(self)
            default:
                true
            }
        case (.some(PlayerEmptyBufferKey), PlayerItemObserverContext):
            if let item = self.playerItem {
                if item.isPlaybackBufferEmpty {
                    self.bufferingState = .delayed
                    self.delegate?.playerBufferingStateDidChange(self)
                }
            }
            
            let status = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).intValue as AVPlayerStatus.RawValue
            
            switch (status) {
            case AVPlayerStatus.readyToPlay.rawValue:
                self.playerView.playerLayer.player = self.player
                self.playerView.playerLayer.isHidden = false
            case AVPlayerStatus.failed.rawValue:
                self.playbackState = PlaybackState.failed
                self.delegate?.playerPlaybackStateDidChange(self)
            default:
                true
            }
        case (.some(PlayerReadyForDisplay), PlayerLayerObserverContext):
            if self.playerView.playerLayer.isReadyForDisplay {
                self.delegate?.playerReady(self)
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            
        }
        
    }
    
}

extension Player {
    
    public func reset() {
    }
    
}

// MARK: - PlayerView

internal class PlayerView: UIView {
    
    var player: AVPlayer! {
        get {
            return (self.layer as! AVPlayerLayer).player
        }
        set {
            (self.layer as! AVPlayerLayer).player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer! {
        get {
            return self.layer as! AVPlayerLayer
        }
    }
    
    var fillMode: String! {
        get {
            return (self.layer as! AVPlayerLayer).videoGravity
        }
        set {
            (self.layer as! AVPlayerLayer).videoGravity = newValue
        }
    }
    
    override class var layerClass : AnyClass {
        return AVPlayerLayer.self
    }
    
    // MARK: object lifecycle
    
    convenience init() {
        self.init(frame: CGRect.zero)
        self.playerLayer.backgroundColor = UIColor.black.cgColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.playerLayer.backgroundColor = UIColor.black.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
