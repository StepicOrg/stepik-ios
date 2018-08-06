//
// Created by Ivan Magda on 06/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct StepProgressNotificationPayload {
    let id: Int
    let isPassed: Bool
}

extension Foundation.Notification.Name {
    public static let stepDone = Foundation.Notification.Name("StepDoneNotificationKey")
}

extension Step {
    static let progressNotification = ObjectNotificationDescriptor<StepProgressNotificationPayload>(name: .stepDone)
}
