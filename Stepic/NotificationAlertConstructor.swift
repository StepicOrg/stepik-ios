//
//  NotificationAlertConstructor.swift
//  Stepic
//
//  Created by Alexander Karpov on 02.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit 
import CRToast

class NotificationAlertConstructor {
    fileprivate init() {}
    static let sharedConstructor = NotificationAlertConstructor()
    
    func getNotificationAlertController() -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("EnableNotificationsTitle", comment: ""), message: NSLocalizedString("EnableNotificationsMessage", comment: ""), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: {
            action in
            NotificationRegistrator.sharedInstance.registerForRemoteNotifications(UIApplication.shared)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Later", comment: ""), style: .cancel, handler: {
            action in
        }))
        
        return alert
    }
    
    func getOpenCommentNotificationViaSafariAlertController(_ success: @escaping ((Void)->Void)) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("NewCommentAlertTitle", comment: ""), message: NSLocalizedString("NewCommentAlertMessage", comment: ""), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: {
            action in
            success()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {
            action in
        }))
        
        return alert
    }
    
    
    func presentNotificationFake(_ text: String, success: @escaping ((Void) -> Void)) {
        
        let responder = CRToastInteractionResponder(interactionType: CRToastInteractionType.tap, automaticallyDismiss: true, block: 
            {
                interactionType in
                success()
            }
        )
        
        let toastOptions : [AnyHashable: Any] = [
            kCRToastImageKey : Images.boundedStepicIcon,
            kCRToastTextKey : text,
            kCRToastNotificationTypeKey : CRToastType.navigationBar.rawValue,
            kCRToastNotificationPresentationTypeKey : CRToastPresentationType.cover.rawValue,
            kCRToastUnderStatusBarKey : true,
            kCRToastAnimationInTypeKey : CRToastAnimationType.gravity.rawValue,
            kCRToastAnimationOutTypeKey : CRToastAnimationType.gravity.rawValue,
            kCRToastAnimationInDirectionKey : CRToastAnimationDirection.top.rawValue,
            kCRToastAnimationOutDirectionKey : CRToastAnimationDirection.top.rawValue,
            kCRToastAnimationInTimeIntervalKey : 0.3,
            kCRToastTimeIntervalKey : 5.0,
            kCRToastAnimationOutTimeIntervalKey : 0.3,
            kCRToastTextMaxNumberOfLinesKey : 2,
            kCRToastImageContentModeKey : UIViewContentMode.scaleAspectFit.rawValue,
            kCRToastBackgroundColorKey: UIColor.black,
            kCRToastInteractionRespondersKey : [responder]
        ]
        
        CRToastManager.showNotification(options: toastOptions) { 
            print("show notificatoin completed!")
        }
        
    }
}
