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
    
    func showConnectionErrorMessage(inController vc: UIViewController) {
        TSMessage.showNotificationInViewController(vc, 
            title: "Connection error", 
            subtitle: "Enable internet connection and retry", 
            image: UIImage(named: "Online-white")!, 
            type: .Error, 
            duration: 3, 
            callback: nil, 
            buttonTitle: nil, 
            buttonCallback: nil, 
            atPosition: TSMessageNotificationPosition.NavBarOverlay, 
            canBeDismissedByUser: true)        
    }
    
    func show3GDownloadErrorMessage(inController vc: UIViewController) {
        TSMessage.showNotificationWithTitle("Only Wi-Fi download enabled", type: .Error)
    }
    
    func showSomethingGotWrong(inController vc: UIViewController) {
        TSMessage.showNotificationWithTitle("Oops", subtitle: "Something just got wrong", type: .Error)
    }
    
    func showReloginPlease(inController vc: UIViewController) {
        TSMessage.showNotificationWithTitle("Authorization problems", subtitle: "Log in, please.", type: .Error)
    }
}

extension Messages : TSMessageViewProtocol {
    func customizeMessageView(messageView: TSMessageView!) {
        messageView.alpha = 0.85
    }
}
