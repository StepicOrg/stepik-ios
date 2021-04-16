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
    var titleColor = UIColor.stepikPrimaryText

    weak var cell: UITableViewCell?

    init(id: String, title: String) {
        self.title = title
        self.id = id
    }
}

final class HeaderMenuBlock: MenuBlock {
}

final class CustomMenuBlock: MenuBlock {
    private(set) var contentView: UIView?

    var onClick: (() -> Void)?

    init(id: String, contentView: UIView) {
        super.init(id: id, title: "")
        self.contentView = contentView
    }
}

class ExpandableMenuBlock: MenuBlock {
    var onExpanded: ((Bool) -> Void)?
    var isExpanded = false
}

final class ContentExpandableMenuBlock: ExpandableMenuBlock {
    weak var contentView: UIView?

    convenience init(id: String, title: String, contentView: UIView?) {
        self.init(id: id, title: title)
        self.contentView = contentView
    }
}

final class ContentMenuBlock: MenuBlock {
    weak var contentView: UIView?
    var buttonTitle: String?
    var onButtonClick: (() -> Void)?

    convenience init(id: String, title: String, contentView: UIView?, buttonTitle: String?, onButtonClick: (() -> Void)?) {
        self.init(id: id, title: title)
        self.contentView = contentView
        self.buttonTitle = buttonTitle
        self.onButtonClick = onButtonClick
    }
}

final class TransitionMenuBlock: MenuBlock {
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

final class SwitchMenuBlock: MenuBlock {
    var onSwitch: ((Bool) -> Void)?
    var isOn: Bool

    init(id: String, title: String, isOn: Bool, onSwitch: ((Bool) -> Void)? = nil) {
        self.onSwitch = onSwitch
        self.isOn = isOn
        super.init(id: id, title: title)
    }
}

final class PlaceholderMenuBlock: MenuBlock {
    func animate() {
        (cell as? PlaceholderTableViewCell)?.startAnimating()
    }
}
