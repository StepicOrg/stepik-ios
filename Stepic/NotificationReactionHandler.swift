//
//  NotificationReactionHandler.swift
//  Stepic
//
//  Created by Alexander Karpov on 13.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

class NotificationReactionHandler {
    fileprivate static func deserializeObject(from userInfo: [AnyHashable: Any]) -> JSON? {
        if let jsonString = userInfo["object"] as? String {
            return JSON(parseJSON: jsonString)
        }
        return nil
    }

    static func handle(with userInfo: [AnyHashable: Any]) -> ((UIViewController) -> Void)? {
        if !AuthInfo.shared.isAuthorized {
            return nil
        }

        if let json = deserializeObject(from: userInfo) {
            let notification = Notification(json: json)
            switch notification.type {
            case .learn:
                return handleLearnNotification(notification)
            case .comments:
                return handleCommentsNotification(notification)
            default:
                break
            }
        }
        return nil
    }

    fileprivate static func handleLearnNotification(_ notification: Notification) -> ((UIViewController) -> Void)? {
        let extractor = NotificationDataExtractor(text: notification.htmlText ?? "", type: notification.type)
        if let courseId = extractor.courseId {
            var course: Course? = nil
            do {
                course = try Course.getCourses([courseId])[0]
            } catch {
                print("handle notification: no course found, id = \(courseId)")
                return nil
            }

            let sectionsCOpt = ControllerHelper.instantiateViewController(identifier: "SectionsViewController") as? SectionsViewController
            if let sectionsController = sectionsCOpt, let course = course {
                sectionsController.course = course

                let res: ((UIViewController) -> Void) = { controller in
                    controller.navigationController?.pushViewController(sectionsController, animated: false)
                }

                return res
            }
        }
        return nil
    }

    fileprivate static func handleCommentsNotification(_ notification: Notification) -> ((UIViewController) -> Void)? {
        let extractor = NotificationDataExtractor(text: notification.htmlText ?? "", type: notification.type)
        if let commentsURL = extractor.commentsURL {
            let res: ((UIViewController) -> Void) = { controller in
                delay(1, closure: {
                    let alert = NotificationAlertConstructor.sharedConstructor.getOpenCommentNotificationViaSafariAlertController({
                        UIThread.performUI {
                            WebControllerManager.sharedManager.presentWebControllerWithURL(commentsURL, inController: controller, withKey: "external link", allowsSafari: true, backButtonStyle: BackButtonStyle.close, animated: true)
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
