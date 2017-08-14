//
//  PlaybackCommandEntity.swift
//  StepticWatches
//
//  Created by Alexander Zimin on 18/12/2016.
//  Copyright © 2016 Alexander Zimin. All rights reserved.
//

import Foundation

@available(iOS 9.0, *)
extension WatchSessionSender.Name {
	static let PlaybackStatus = WatchSessionSender.Name("PlaybackStatus")
	static let RequestPlaybackStatus = WatchSessionSender.Name("RequestPlaybackStatus")
}

struct PlaybackStatusEntity: DataConvertable {
	enum Status: Int {
		case available
		case noVideo
		case pause
		case play
	}

	var status: Status

	init(status: Status) {
		self.status = status
	}

	init(dictionary: [String: AnyObject]) {
		self.status = Status(rawValue: dictionary["status"] as! Int)!
	}

	func toDictionary() -> [String: AnyObject] {
		return ["status": status.rawValue as AnyObject]
	}
}
