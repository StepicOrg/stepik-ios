//
//  CourseWidgetLabel?.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 14.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

extension CourseWidgetLabel {
    struct Appearance {
        let lineSpacing: CGFloat = 1.9
        let maxLinesCount = 3

        var font = UIFont.systemFont(ofSize: 16, weight: .regular)

        let lightModeTextColor = UIColor.mainText
        let darkModeTextColor = UIColor.white
    }
}

final class CourseWidgetLabel: UILabel {
    let appearance: Appearance

    var colorMode: CourseWidgetColorMode {
        didSet {
            self.updateColor()
        }
    }

    init(
        frame: CGRect,
        colorMode: CourseWidgetColorMode = .default,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.colorMode = colorMode
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateColor() {
        self.textColor = self.getTextColor(for: self.colorMode)
    }
}

extension CourseWidgetLabel: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.updateColor()
        self.font = self.appearance.font
        self.numberOfLines = self.appearance.maxLinesCount
    }
}

// MARK: - ColorMode

extension CourseWidgetLabel {
    private func getTextColor(for colorMode: CourseWidgetColorMode) -> UIColor {
        switch colorMode {
        case .light:
            return self.appearance.lightModeTextColor
        case .dark:
            return self.appearance.darkModeTextColor
        }
    }
}
