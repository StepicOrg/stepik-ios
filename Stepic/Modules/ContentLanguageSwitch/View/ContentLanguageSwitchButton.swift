//
//  ContentLanguageSwitchButton.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class ContentLanguageSwitchButton: BounceButton {
    enum Appearance {
        static let selectedBackgroundColor = UIColor.mainDark
        static let unselectedBackgroundColor = UIColor(hex: 0x535366, alpha: 0.06)

        static let selectedTextColor = UIColor.white
        static let unselectedTextColor = UIColor.mainText

        static let font = UIFont.systemFont(ofSize: 16, weight: .light)
    }

    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.setSelectedState()
            } else {
                self.setUnselectedState()
            }
        }
    }

    private func setSelectedState() {
        self.backgroundColor = Appearance.selectedBackgroundColor
        self.titleLabel?.font = Appearance.font
        self.setTitleColor(Appearance.selectedTextColor, for: .selected)
    }

    private func setUnselectedState() {
        self.backgroundColor = Appearance.unselectedBackgroundColor
        self.titleLabel?.font = Appearance.font
        self.setTitleColor(Appearance.unselectedTextColor, for: .normal)
    }
}
