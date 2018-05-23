//
//  MenuBlocks.swift
//  Stepic
//
//  Created by Ostrenkiy on 29.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class MenuBlock {
    var hasSeparatorOnBottom = true
    let id: String
    var title: String
    var onAppearance: (() -> Void)?
    var isSelectable = false
    var titleColor: UIColor = UIColor.mainText

    weak var cell: UITableViewCell?

    init(id: String, title: String) {
        self.title = title
        self.id = id
    }
}

class HeaderMenuBlock: MenuBlock {
}

class ExpandableMenuBlock: MenuBlock {
    var onExpanded: ((Bool) -> Void)?
    var isExpanded: Bool = false
}

class TitleContentExpandableMenuBlock: ExpandableMenuBlock {
    typealias TitleContent = (title: String, content: String)
    var content: [TitleContent] = []
}

class PinsMapExpandableMenuBlock: ExpandableMenuBlock {
    var pins: [Int] = []
}

class TransitionMenuBlock: MenuBlock {
    var subtitle: String? {
        didSet {
            (cell as? TransitionMenuBlockTableViewCell)?.subtitleLabel.text = subtitle
        }
    }
    var onTouch: (() -> Void)?
    var onCameBack: (() -> Void)?

    override init(id: String, title: String) {
        super.init(id: id, title: title)
        isSelectable = true
    }
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

class PlaceholderMenuBlock: MenuBlock {
    func animate() {
        (cell as? PlaceholderTableViewCell)?.startAnimating()
    }
}
