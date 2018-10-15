//
//  TabBarRouter.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class TabBarRouter: SourcelessRouter, RouterProtocol {
    var tab: Tab

    init(tab: Tab) {
        self.tab = tab
    }

    func route() {
        currentTabBarController?.selectedIndex = tab.rawValue
    }

    enum Tab: Int {
        case home
        case catalog
        case profile
        case certificates
        case notifications
    }
}
