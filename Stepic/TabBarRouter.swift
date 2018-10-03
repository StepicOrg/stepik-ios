//
//  TabBarRouter.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class TabBarRouter: SourcelessRouter, RouterProtocol {
    var tab: Int

    init(tab: Int) {
        self.tab = tab
    }

    func route() {
        currentTabBarController?.selectedIndex = tab
    }
}
