//
//  NotificationNameExtension.swift
//  StepikTV
//
//  Created by Александр Пономарев on 06.02.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static let courseSubscribed = NSNotification.Name("courseSubscribed")
    static let courseUnsubscribed = NSNotification.Name("courseUnsubscribed")
    static let stepUpdated = NSNotification.Name("stepUpdated")
    static let userLoggedOut = NSNotification.Name("userLoggedOut")
    static let userLoggedIn = NSNotification.Name("userLoggedIn")
}
