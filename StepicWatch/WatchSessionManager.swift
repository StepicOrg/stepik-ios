//
//  WatchSessionManager.swift
//  WatchOS3ComplicationExample
//
//  Created by Vadim Drobinin on 18/12/16.
//  Copyright © 2016 Vadim Drobinin. All rights reserved.
//

import WatchConnectivity
import WatchKit

@available(iOS 9.0, *)
class TypeWeakContainer {
	weak var value: WatchSessionDataObserver?

	init(_ value: WatchSessionDataObserver) {
		self.value = value
	}
}

@available(iOS 9.0, *)
class WatchSessionManager: NSObject, WCSessionDelegate {

	static let sharedManager = WatchSessionManager()
	private override init() {
		super.init()
	}

	fileprivate var observers: [TypeWeakContainer] = []

	func addObserver(_ observer: WatchSessionDataObserver) {
		let container = TypeWeakContainer(observer)
		removeObserver(observer)
		observers.append(container)
		sendDataToObserver(observer, data: contextContainer)
	}

	func removeObserver(_ observer: WatchSessionDataObserver) {
		var index = 0
		var finded = false
		for el in observers {
			if el.value?.compare(toObject: observer) ?? false {
				finded = true
				break
			}
			index += 1
		}
		if finded {
			observers.remove(at: index)
		}
	}

	func sendDataToAllObservers(data: [String: Any]) {
		for observer in self.observers {
			if let value = observer.value {
				sendDataToObserver(value, data: data)
			}
		}
	}

	func sendDataToObserver(_ observer: WatchSessionDataObserver, data: [String: Any]) {
		let observerKeys = observer.keysForObserving
		for (key, value) in data {
			let keyName = WatchSessionSender.Name(key)
			if observerKeys.contains(keyName) {
				observer.recieved(data: value, forKey: keyName)
			}
		}
	}

	private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil

	@available(iOS 9.3, *)
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
	}

	#if os(iOS)
	func sessionDidBecomeInactive(_ session: WCSession) {
	}
	func
		sessionDidDeactivate(_ session: WCSession) {
	}
	#endif

	var validSession: WCSession? {
		#if os(iOS)
			if let session = session, session.isPaired && session.isWatchAppInstalled {
				return session
			}
		#elseif os(watchOS)
			return session
		#endif
        return nil
	}

	func startSession() {
		session?.delegate = self
		session?.activate()
	}

	var contextContainer: [String: Any] = [:]
}

@available(iOS 9.0, *)
extension WatchSessionManager {
	func updateApplicationContext(applicationContext: [WatchSessionSender.Name : Any]) throws {
		var newMessage: [String: AnyObject] = [:]
		for (key, value) in applicationContext {
			newMessage[key.rawValue] = value as AnyObject
		}
		try updateApplicationContext(applicationContext: newMessage)
	}

	func updateApplicationContext(applicationContext: [String : AnyObject]) throws {
		if let session = validSession {
			do {
				try session.updateApplicationContext(applicationContext)
			} catch let error {
				throw error
			}
		}
	}

	func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
		DispatchQueue.main.async {
			for (key, value) in applicationContext {
				self.contextContainer[key] = value
        self.executeMetainfoCheck(key: key, value: value)
			}
			self.sendDataToAllObservers(data: applicationContext)
		}
	}

  func executeMetainfoCheck(key: String, value: Any) {
    // IS kind of metainfo container
    if key.hasPrefix(WatchSessionSender.Name.Metainfo.rawValue) && key != WatchSessionSender.Name.Metainfo.rawValue {
      UserDefaults.standard.set(value, forKey: key)
    }
  }
}

// MARK: User Info
@available(iOS 9.0, *)
extension WatchSessionManager {

	func transferUserInfo(userInfo: [String : Any]) -> WCSessionUserInfoTransfer? {
		return validSession?.transferUserInfo(userInfo)
	}

	func transferCurrentComplicationUserInfo(userInfo: [String : Any]) -> WCSessionUserInfoTransfer? {
		#if os(iOS)
			return validSession?.transferCurrentComplicationUserInfo(userInfo)
		#elseif os(watchOS)
			return nil
		#endif
	}

	@objc(session:didFinishUserInfoTransfer:error:) func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
		// implement this on the sender if you need to confirm that
		// the user info did in fact transfer
	}

	func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
		// handle receiving user info
		DispatchQueue.main.async {
			print("Received: \(userInfo)")
			// Update UI from here
		}
	}

}

// MARK: Transfer File
@available(iOS 9.0, *)
extension WatchSessionManager {

	// Sender
	func transferFile(file: NSURL, metadata: [String : AnyObject]) -> WCSessionFileTransfer? {
		return validSession?.transferFile(file as URL, metadata: metadata)
	}

	@objc(session:didFinishFileTransfer:error:) func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
		// handle filed transfer completion
	}

	// Receiver
	@objc(session:didReceiveFile:) func session(_ session: WCSession, didReceive file: WCSessionFile) {
		// handle receiving file
		DispatchQueue.main.async {

			// make sure to put on the main queue to update UI!
		}
	}
}

// MARK: Interactive Messaging
@available(iOS 9.0, *)
extension WatchSessionManager {

	// Live messaging! App has to be reachable
	private var validReachableSession: WCSession? {
		if let session = validSession, session.isReachable {
			return session
		}
		return nil
	}

	// Sender

	func sendMessage(message: [WatchSessionSender.Name : Any],
	                 replyHandler: (([String : Any]) -> Void)? = nil,
	                 errorHandler: ((Error) -> Void)? = nil) -> Bool {
		var newMessage: [String: Any] = [:]
		for (key, value) in message {
			newMessage[key.rawValue] = value
		}

		return sendMessage(message: newMessage, replyHandler: replyHandler, errorHandler: errorHandler)
	}

	func sendMessage(message: [String : Any],
	                 replyHandler: (([String : Any]) -> Void)? = nil,
	                 errorHandler: ((Error) -> Void)? = nil) -> Bool {
		validReachableSession?.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler)
		return validReachableSession != nil
	}

	func sendMessageData(data: Data,
	                     replyHandler: ((Data) -> Void)? = nil,
	                     errorHandler: ((Error) -> Void)? = nil) {
		validReachableSession?.sendMessageData(data, replyHandler: replyHandler, errorHandler: errorHandler)
	}

	func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
		DispatchQueue.main.async {
      for (key, value) in message {
        self.contextContainer[key] = value
      }
			self.sendDataToAllObservers(data: message)
			// make sure to put on the main queue to update UI!
		}
	}

	// Receiver
	func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
		// handle receiving message

	}

	func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
		// handle receiving message data
		DispatchQueue.main.async {
			// make sure to put on the main queue to update UI!
		}
	}
}
