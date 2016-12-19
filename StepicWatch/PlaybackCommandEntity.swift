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
	static let PlaybackCommand = WatchSessionSender.Name("PlaybackCommand")
}

struct PlaybackCommandEntity: DataConvertable {
	enum Command: Int {
		case Play
		case Pause
		case Forward
		case Backward
	}
	
	var command: Command
	
	init(command: Command) {
		self.command = command
	}
	
	init(dictionary: [String: AnyObject]) {
		self.command = Command(rawValue: dictionary["command"] as! Int)!
	}
	
	func toDictionary() -> [String: AnyObject] {
		return ["command": command.rawValue as AnyObject]
	}
}
