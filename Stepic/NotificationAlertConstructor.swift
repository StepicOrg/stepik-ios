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
    private init() {}
    static let sharedConstructor = NotificationAlertConstructor()
    
    func getNotificationAlertController() -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("EnableNotificationsTitle", comment: ""), message: NSLocalizedString("EnableNotificationsMessage", comment: ""), preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .Default, handler: {
            action in
            NotificationRegistrator.sharedInstance.registerForRemoteNotifications(UIApplication.sharedApplication())
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Later", comment: ""), style: .Cancel, handler: {
            action in
        }))
        
        return alert
    }
    
    func getOpenCommentNotificationViaSafariAlertController(success: (Void->Void)) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("NewCommentAlertTitle", comment: ""), message: NSLocalizedString("NewCommentAlertMessage", comment: ""), preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .Default, handler: {
            action in
            success()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: {
            action in
        }))
        
        return alert
    }
    
    
    func presentNotificationFake(text: String, success: (Void -> Void)) {
        
        let responder = CRToastInteractionResponder(interactionType: CRToastInteractionType.Tap, automaticallyDismiss: true, block: 
            {
                interactionType in
                success()
            }
        )
        
        let toastOptions : [NSObject: AnyObject] = [
            kCRToastImageKey : Images.boundedStepicIcon,
            kCRToastTextKey : text,
            kCRToastNotificationTypeKey : CRToastType.NavigationBar.rawValue,
            kCRToastNotificationPresentationTypeKey : CRToastPresentationType.Cover.rawValue,
            kCRToastUnderStatusBarKey : true,
            kCRToastAnimationInTypeKey : CRToastAnimationType.Gravity.rawValue,
            kCRToastAnimationOutTypeKey : CRToastAnimationType.Gravity.rawValue,
            kCRToastAnimationInDirectionKey : CRToastAnimationDirection.Top.rawValue,
            kCRToastAnimationOutDirectionKey : CRToastAnimationDirection.Top.rawValue,
            kCRToastAnimationInTimeIntervalKey : 0.3,
            kCRToastTimeIntervalKey : 5.0,
            kCRToastAnimationOutTimeIntervalKey : 0.3,
            kCRToastTextMaxNumberOfLinesKey : 2,
            kCRToastImageContentModeKey : UIViewContentMode.ScaleAspectFit.rawValue,
            kCRToastBackgroundColorKey: UIColor.blackColor(),
            kCRToastInteractionRespondersKey : [responder]
        ]
        
        CRToastManager.showNotificationWithOptions(toastOptions) { 
            print("show notificatoin completed!")
        }
        
    }
}
