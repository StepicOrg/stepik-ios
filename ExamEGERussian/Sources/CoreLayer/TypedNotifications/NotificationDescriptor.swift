//
// Created by Ivan Magda on 06/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation

public struct NotificationDescriptor<A> {
    let name: Foundation.Notification.Name
    let convert: (Foundation.Notification) -> A
}
