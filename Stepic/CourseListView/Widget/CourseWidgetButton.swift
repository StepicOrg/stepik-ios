//
//  CourseWidgetButton.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 14.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

extension CourseWidgetButton {
    struct Appearance {
        let cornerRadius: CGFloat = 8.0

        let titleFont = UIFont.systemFont(ofSize: 14, weight: .regular)

        let lightModeTextColor = UIColor.mainText
        let lightModeBackgroundColor = UIColor(hex: 0x535366, alpha: 0.06)

        let lightModeCallToActionTextColor = UIColor.stepicGreen
        let lightModeCallToActionBackgroundColor = UIColor.stepicGreen.withAlphaComponent(0.1)

        let darkModeTextColor = UIColor.white
        let darkModeBackgroundColor = UIColor(hex: 0xffffff, alpha: 0.1)

        let darkModeCallToActionTextColor = UIColor.stepicGreen
        let darkModeCallToActionBackgroundColor = UIColor.stepicGreen.withAlphaComponent(0.1)
    }
}

final class CourseWidgetButton: BounceButton {
    let appearance: Appearance

    var colorMode: CourseWidgetColorMode {
        didSet {
            self.updateColors()
        }
    }

    var isCallToAction: Bool {
        didSet {
            self.updateColors()
        }
    }

    init(
        colorMode: CourseWidgetColorMode = .default,
        isCallToAction: Bool = false,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.colorMode = colorMode
        self.isCallToAction = isCallToAction
        super.init(frame: .zero)
        self.setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateColors() {
        self.backgroundColor = self.getBackgroundColor(
            for: self.colorMode,
            isCallToAction: self.isCallToAction
        )
        self.setTitleColor(
            self.getTextColor(for: self.colorMode, isCallToAction: self.isCallToAction),
            for: .normal
        )
    }
}

extension CourseWidgetButton: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.titleLabel?.font = self.appearance.titleFont

        self.clipsToBounds = true
        self.layer.cornerRadius = self.appearance.cornerRadius
    }
}

// MARK: - ColorMode

extension CourseWidgetButton {
    private func getTextColor(
        for colorMode: CourseWidgetColorMode,
        isCallToAction: Bool
    ) -> UIColor {
        switch colorMode {
        case .light:
            return isCallToAction
                ? self.appearance.lightModeCallToActionTextColor
                : self.appearance.lightModeTextColor
        case .dark:
            return isCallToAction
                ? self.appearance.darkModeCallToActionTextColor
                : self.appearance.darkModeTextColor
        }
    }

    private func getBackgroundColor(
        for colorMode: CourseWidgetColorMode,
        isCallToAction: Bool
    ) -> UIColor {
        switch colorMode {
        case .light:
            return isCallToAction
                ? self.appearance.lightModeCallToActionBackgroundColor
                : self.appearance.lightModeBackgroundColor
        case .dark:
            return isCallToAction
                ? self.appearance.darkModeCallToActionBackgroundColor
                : self.appearance.darkModeBackgroundColor
        }
    }
}
