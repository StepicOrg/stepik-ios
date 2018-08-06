//
// Created by Ivan Magda on 06/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation

public final class NotificationToken {
    let token: NSObjectProtocol
    let center: NotificationCenter

    init(token: NSObjectProtocol, center: NotificationCenter) {
        self.token = token
        self.center = center
    }

    deinit {
        center.removeObserver(token)
    }
}
