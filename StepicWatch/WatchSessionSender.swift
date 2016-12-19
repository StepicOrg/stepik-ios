//
//  WatchSessionSender.swift
//  StepticWatches
//
//  Created by Alexander Zimin on 18/12/2016.
//  Copyright © 2016 Alexander Zimin. All rights reserved.
//

import Foundation

@available(iOS 9.0, *)
class WatchSessionSender {
	
	static func requestCourses() -> Bool {
		return WatchSessionManager.sharedManager.sendMessage(message: [WatchSessionSender.Name.RequestPlaybackStatus: ""])
	}
	
	static func requestStatus() -> Bool {
		return WatchSessionManager.sharedManager.sendMessage(message: [WatchSessionSender.Name.RequestPlaybackStatus: ""])
	}
	
	static func sendPlaybackStatus(_ status: PlaybackStatusEntity.Status) {
		let statusEntity = PlaybackStatusEntity(status: status)
		_ = WatchSessionManager.sharedManager.sendMessage(message: [WatchSessionSender.Name.PlaybackStatus: statusEntity.toData()])
	}
	
	static func sendPlaybackCommand(_ command: PlaybackCommandEntity.Command) {
		let commandEntity = PlaybackCommandEntity(command: command)
		_ = WatchSessionManager.sharedManager.sendMessage(message: [WatchSessionSender.Name.PlaybackCommand: commandEntity.toData()])
	}
	
	struct Name: RawRepresentable, Equatable, Hashable, Comparable {
		let rawValue: String
		typealias RawValue = String
		
		public init(_ rawValue: String) {
			self.rawValue = rawValue
		}
		
		public init(rawValue: String) {
			self.rawValue = rawValue
		}
		
		var hashValue: Int {
			return rawValue.hash
		}
		
		static func <(lhs: Name, rhs: Name) -> Bool {
			return lhs.rawValue < rhs.rawValue
		}
		
		static func ==(lhs: Name, rhs: Name) -> Bool {
			return lhs.rawValue == rhs.rawValue
		}
	}
}
