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
    fileprivate override init() {
        super.init()
        TSMessage.setDelegate(self)
        TSMessage.addCustomDesignFromFile(withName: "CustomMessagesDesign.json")
    }

    func showConnectionErrorMessage(inController vc: UIViewController) {
        TSMessage.showNotification(in: vc,
            title: NSLocalizedString("ConnectionErrorTitle", comment: ""),
            subtitle: NSLocalizedString("ConnectionErrorSubtitle", comment: ""),
            image: UIImage(named: "Online-white")!,
            type: .error,
            duration: 3,
            callback: nil,
            buttonTitle: nil,
            buttonCallback: nil,
            at: TSMessageNotificationPosition.navBarOverlay,
            canBeDismissedByUser: true)
    }

    func show3GDownloadErrorMessage(inController vc: UIViewController) {
        TSMessage.showNotification(withTitle: NSLocalizedString("DownloadReachabilityErrorTitle", comment: ""), type: .error)
    }

    func showSomethingGotWrong(inController vc: UIViewController) {
        TSMessage.showNotification(withTitle: NSLocalizedString("SomethingWrongTitle", comment: ""), subtitle: NSLocalizedString("SomethingWrongSubtitle", comment: ""), type: .error)
    }

    func showReloginPlease(inController vc: UIViewController) {
        TSMessage.showNotification(withTitle: NSLocalizedString("ReloginTitle", comment: ""), subtitle: NSLocalizedString("ReloginSubtitle", comment: ""), type: .error)
    }

    func showCancelledDownloadMessage(count: Int) {
        TSMessage.showNotification(withTitle: NSLocalizedString("ConnectionLost", comment: ""), subtitle: "\(NSLocalizedString("CancelledDownload", comment: "")) \(count) \(NSLocalizedString((count%10 == 1 && count != 11) ? "Video" : "Videos", comment: ""))", type: .error)
    }
}

extension Messages : TSMessageViewProtocol {
    func customize(_ messageView: TSMessageView!) {
        messageView.alpha = 0.85
    }
}
