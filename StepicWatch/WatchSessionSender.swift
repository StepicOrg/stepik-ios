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

  static func sendPlainCourses(_ courses: [CoursePlainEntity]) {
    let data = [WatchSessionSender.Name.Courses: courses.toData()]
    let success = WatchSessionManager.sharedManager.sendMessage(message: data)

    if !success {
      do {
        try WatchSessionManager.sharedManager.updateApplicationContext(applicationContext: data)
      } catch { }
    }
  }

  static func sendMetainfo(metainfoContainer: CourseMetainfoContainer) {
    let data = [WatchSessionSender.Name.Metainfo: metainfoContainer.toData()]
    let success = WatchSessionManager.sharedManager.sendMessage(message: data)

    if !success {
      do {
        let contextData = [WatchSessionSender.Name.Metainfo(courseId: metainfoContainer.courseId): metainfoContainer.toData()]
        try WatchSessionManager.sharedManager.updateApplicationContext(applicationContext: contextData)
      } catch { }
    }
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

		static func < (lhs: Name, rhs: Name) -> Bool {
			return lhs.rawValue < rhs.rawValue
		}

		static func == (lhs: Name, rhs: Name) -> Bool {
			return lhs.rawValue == rhs.rawValue
		}

    public init(stringLiteral value: String) {
      self.rawValue = value
    }
	}
}
