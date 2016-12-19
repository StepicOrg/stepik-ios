//
//  WatchSessionDataObserver.swift
//  StepticWatches
//
//  Created by Alexander Zimin on 18/12/2016.
//  Copyright © 2016 Alexander Zimin. All rights reserved.
//

import Foundation

protocol WatchSessionDataObserver {
	var identifier: String { get }
	
	var keysForObserving: [WatchSessionSender.Name] { get }
	func recieved(data: Any, forKey key: WatchSessionSender.Name)
}

extension WatchSessionDataObserver {
	func compare(toObject: WatchSessionDataObserver) -> Bool {
		return self.identifier == toObject.identifier
	}
}

extension WatchSessionDataObserver where Self: NSObject {
	var identifier: String {
		return String(self.hashValue)
	}
}
