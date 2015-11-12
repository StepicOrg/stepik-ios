//
//  Messages.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import TSMessages

class Messages: NSObject {
    static let sharedManager = Messages()
    private override init() {
        super.init()
        TSMessage.setDelegate(self)
        TSMessage.addCustomDesignFromFileWithName("CustomMessagesDesign.json")
    }
    
    func showConnectionErrorMessage() {
        TSMessage.showNotificationWithTitle("Connection error", subtitle: "Enable internet connection and retry", type: TSMessageNotificationType.Error)
    }
    
    func show3GDownloadErrorMessage() {
        TSMessage.showNotificationWithTitle("Only Wi-Fi download enabled", type: .Error)
    }
    
    func showSomethingGotWrong() {
        TSMessage.showNotificationWithTitle("Oops", subtitle: "Something just got wrong", type: .Error)
    }
    
    func showReloginPlease() {
        TSMessage.showNotificationWithTitle("Authorization problems", subtitle: "Log in, please.", type: .Error)
    }
}

extension Messages : TSMessageViewProtocol {
    func customizeMessageView(messageView: TSMessageView!) {
        messageView.alpha = 0.85
    }
}
