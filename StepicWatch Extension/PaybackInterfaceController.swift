//
//  PaybackInterfaceController.swift
//  StepticWatches
//
//  Created by Alexander Zimin on 17/12/2016.
//  Copyright © 2016 Alexander Zimin. All rights reserved.
//

import WatchKit
import Foundation

enum PlaybackStatus {
	case Seaching
	case Enable
	case Disable
	case NoVideo
}

extension PaybackInterfaceController: WatchSessionDataObserver {
	var keysForObserving: [WatchSessionSender.Name] {
		return [.PlaybackStatus]
	}

	func recieved(data: Any, forKey key: WatchSessionSender.Name) {
		if key == .PlaybackStatus {
			let statusEntity = PlaybackStatusEntity(data: data as! Data)
			switch statusEntity.status {
			case .available:
				status = .Enable
			case .noVideo:
				status = .NoVideo
			case .pause:
				status = .Enable
				isOnPlay = false
			case .play:
				status = .Enable
				isOnPlay = true
			}
		}
	}
}

class PaybackInterfaceController: WKInterfaceController {

	@IBOutlet var statusLabel: WKInterfaceLabel!

	@IBOutlet var buttonsGroup: WKInterfaceGroup!
	@IBOutlet var playButton: WKInterfaceButton!

	@IBOutlet var backButton: WKInterfaceButton!
	@IBOutlet var forwardButton: WKInterfaceButton!

	var status: PlaybackStatus = .Seaching {
		didSet {

			statusLabel.setHidden(false)
			enable = false

			switch status {
			case .Seaching:
				statusLabel.setText(Localizables.searchingForDevice)
			case .Enable:
				statusLabel.setHidden(true)
				enable = true
			case .Disable:
				statusLabel.setText(Localizables.notAvailable)
			case .NoVideo:
				statusLabel.setText(Localizables.videoNotFound)
			}
		}
	}

	var enable: Bool = false {
		didSet {
			buttonsGroup.setAlpha(enable ? 1.0 : 0.4)
			playButton.setEnabled(enable)
			backButton.setEnabled(enable)
			forwardButton.setEnabled(enable)
		}
	}

	var isOnPlay: Bool = false {
		didSet {
			playButton.setTitle(isOnPlay ? Localizables.pause : Localizables.play)
		}
	}

	override func awake(withContext context: Any?) {
		super.awake(withContext: context)

	}

	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()

		WatchSessionManager.sharedManager.addObserver(self)

		enable = false
		isOnPlay = false
		status = .Seaching

		if !WatchSessionSender.requestStatus() {
			status = .Disable
		}
	}

	override func willDisappear() {
		super.willDisappear()

		WatchSessionManager.sharedManager.removeObserver(self)
	}

	@IBAction func playButtonAction() {
		isOnPlay = !isOnPlay
		WatchSessionSender.sendPlaybackCommand(isOnPlay ? .pause : .play)
	}

	@IBAction func backButtonAction() {
		WatchSessionSender.sendPlaybackCommand(.backward)
	}

	@IBAction func forwardButtonAction() {
		WatchSessionSender.sendPlaybackCommand(.forward)
	}
}
