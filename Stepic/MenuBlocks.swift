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
    var title: String
    var onAppearance: ((Void) -> Void)?
    
    init(title: String, hasSeparatorOnBottom: Bool = false, onAppearance: ((Void) -> Void)? = nil) {
        self.title = title
        self.hasSeparatorOnBottom = hasSeparatorOnBottom
    }
}

class ExpandableMenuBlock: MenuBlock {
    var expandedText: String
    var onExpansion: ((Bool) -> Void)?
    
    init(title: String, hasSeparatorOnBottom: Bool = false, onAppearance: ((Void) -> Void)? = nil, expandedText: String, onExpansion: ((Bool) -> Void)? = nil) {
        super.init(title: title, hasSeparatorOnBottom: hasSeparatorOnBottom, onAppearance: onAppearance)
        self.expandedText = expandedText
        self.onExpansion = onExpansion
    }
}

class TransitionMenuBlock: MenuBlock {
    var subtitle: String?
    var onTouch: ((UIViewController) -> Void)?
    
    init(title: String, hasSeparatorOnBottom: Bool = false, onAppearance: ((Void) -> Void)? = nil, subtitle: String? = nil, onTouch: ((UIViewController) -> Void)?) {
        super.init(title: title, hasSeparatorOnBottom: hasSeparatorOnBottom, onAppearance: onAppearance)
        self.subtitle = subtitle
        self.onTouch = onTouch
    }
}

class SwitchMenuBlock: MenuBlock {
    var onSwitch: ((Bool) -> Void)?
    
    init(title: String, hasSeparatorOnBottom: Bool = false, onAppearance: ((Void) -> Void)? = nil, onSwitch: (() -> Void)?) {
        super.init(title: title, hasSeparatorOnBottom: hasSeparatorOnBottom, onAppearance: onAppearance)
        self.onSwitch = onSwitch
    }
}
