//
//  NotificationsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 26.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol NotificationsView: class {

}

class NotificationsPresenter {
    weak var view: NotificationsView?

    init(view: NotificationsView) {
        self.view = view
    }
}
