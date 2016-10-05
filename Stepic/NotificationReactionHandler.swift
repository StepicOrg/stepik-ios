//
//  NotificationReactionHandler.swift
//  Stepic
//
//  Created by Alexander Karpov on 13.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 Chooses the appropriate reaction to the notification click
 */
class NotificationReactionHandler {
    
    fileprivate func deserializeObject(from userInfo:[AnyHashable: Any]) -> [String: AnyObject]? {
        let jsonString = userInfo["object"] as? NSString
        if let data = jsonString?.data(using: String.Encoding.utf8.rawValue) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                return json as? [String : AnyObject]
            }
            catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func handleNotificationWithUserInfo(_ userInfo: [AnyHashable: Any]) -> ((UIViewController) -> Void)? {
        
        if !AuthInfo.shared.isAuthorized {
            return nil
        }
        
        if let notificationObject : [String: AnyObject] = deserializeObject(from: userInfo) {
            print(notificationObject)
            if let notification = Notification(dictionary: notificationObject) {
                switch notification.type {
                case NotificationType.Learn:
                    return handleLearnNotification(notification)
                case NotificationType.Comments:
                    return handleCommentsNotification(notification)
                }
            }
        }
        return nil
    }
    
    fileprivate func handleLearnNotification(_ notification: Notification) -> ((UIViewController) -> Void)? {
        let extractor = NotificationDataExtractor(notification: notification)
        if let courseId = extractor.getCourseId() {
            
            var course : Course? = nil
            do { 
                course = try Course.getCourses([courseId])[0]
            } 
            catch {
                print("No course with appropriate id \(courseId) found")
                return nil
            }
            let sectionsCOpt = ControllerHelper.instantiateViewController(identifier: "SectionsViewController") as? SectionsViewController
            print(sectionsCOpt)
            if let sectionsController = sectionsCOpt,
                let course = course {
                sectionsController.course = course
                
                let res : ((UIViewController) -> Void) = {
                    controller in
                    print("in res handler -> \(controller)")
                    controller.navigationController?.pushViewController(sectionsController, animated: false)
                }
                
                return res
            }
        } 
        return nil
    }
    
    fileprivate func handleCommentsNotification(_ notification: Notification) -> ((UIViewController) -> Void)? {
        let extractor = NotificationDataExtractor(notification: notification)
        if let commentsURL = extractor.getCommentsURL() {     
            
            let res : ((UIViewController) -> Void) = {
                controller in
                
                delay(1, closure: {
                    let alert = NotificationAlertConstructor.sharedConstructor.getOpenCommentNotificationViaSafariAlertController({
                        UIThread.performUI {
                            WebControllerManager.sharedManager.presentWebControllerWithURL(commentsURL, inController: controller, withKey: "external link", allowsSafari: true, backButtonStyle:    BackButtonStyle.close, animated: true)
                        }
                    })
                    controller.present(alert, animated: true, completion: nil)
                })  
            }
            return res

        } 
        return nil
    }
    
}
