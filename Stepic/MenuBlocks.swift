//
//  MenuBlocks.swift
//  Stepic
//
//  Created by Ostrenkiy on 29.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class MenuBlock {
    var hasSeparatorOnBottom = false
    let id: String
    var title: String
    var onAppearance: ((Void) -> Void)?
    
    init(id: String, title: String) {
        self.title = title
        self.id = id
    }
}

class ExpandableMenuBlock: MenuBlock {
    var onExpanded: ((Bool) -> Void)?
}

class TitleContentExpandableMenuBlock: ExpandableMenuBlock {
    typealias TitleContent = (title: String, content: String)
    var content: [TitleContent] = []
    var substitutesTitle: Bool = false
}

class TransitionMenuBlock: MenuBlock {
    var subtitle: String?
    var onTouch: ((UIViewController) -> Void)?
    var onCameBack: ((Void) -> Void)?
}

class SwitchMenuBlock: MenuBlock {
    var onSwitch: ((Bool) -> Void)?
    var isOn: Bool
    
    init(id: String, title: String, isOn: Bool, onSwitch: ((Bool) -> Void)? = nil) {
        self.onSwitch = onSwitch
        self.isOn = isOn
        super.init(id: id, title: title)
    }
}
