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
            title: NSLocalizedString("ConnectionErrorTitle", comment: ""), 
            subtitle: NSLocalizedString("ConnectionErrorSubtitle", comment: ""), 
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
        TSMessage.showNotificationWithTitle(NSLocalizedString("DownloadReachabilityErrorTitle", comment: ""), type: .Error)
    }
    
    func showSomethingGotWrong(inController vc: UIViewController) {
        TSMessage.showNotificationWithTitle(NSLocalizedString("SomethingWrongTitle", comment: ""), subtitle: NSLocalizedString("SomethingWrongSubtitle", comment: ""), type: .Error)
    }
    
    func showReloginPlease(inController vc: UIViewController) {
        TSMessage.showNotificationWithTitle(NSLocalizedString("ReloginTitle", comment: ""), subtitle: NSLocalizedString("ReloginSubtitle", comment: ""), type: .Error)
    }
    
    func showCancelledDownloadMessage(count count : Int) {
        TSMessage.showNotificationWithTitle(NSLocalizedString("ConnectionLost", comment: ""), subtitle: "\(NSLocalizedString("CancelledDownload", comment: "")) \(count) \(NSLocalizedString((count%10 == 1 && count != 11) ? "Video" : "Videos", comment: ""))", type: .Error)
    }
}

extension Messages : TSMessageViewProtocol {
    func customizeMessageView(messageView: TSMessageView!) {
        messageView.alpha = 0.85
    }
}
