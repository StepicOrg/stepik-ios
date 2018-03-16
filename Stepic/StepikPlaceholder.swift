//
//  StepikPlaceholder.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 16.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

typealias StepikPlaceholderStyle = StepikPlaceholder.Style

class StepikPlaceholder {
    class var availablePlaceholders: [StepikPlaceholderStyle] {
        return [Style.empty, Style.noConnection]
    }

    var style: StepikPlaceholderStyle
    var buttonAction: (() -> Void)?

    init(_ style: StepikPlaceholderStyle, action: (() -> Void)?) {
        self.style = style
        self.buttonAction = action
    }

    class Style: Equatable {
        typealias PlaceholderImage = (image: UIImage, scale: CGFloat)
        typealias PlaceholderId = String

        private(set) var id: PlaceholderId
        private(set) var image: PlaceholderImage?
        private(set) var text: String
        private(set) var buttonTitle: String?

        init(id: PlaceholderId, image: PlaceholderImage?, text: String, buttonTitle: String?) {
            self.id = id
            self.image = image
            self.text = text
            self.buttonTitle = buttonTitle
        }

        public static func == (lhs: StepikPlaceholderStyle, rhs: StepikPlaceholderStyle) -> Bool {
            return lhs.id == rhs.id
        }
    }
}

extension StepikPlaceholder.Style {
    static let empty = StepikPlaceholderStyle(id: "empty", image: PlaceholderImage(image: #imageLiteral(resourceName: "empty-empty"), scale: 0.99), text: NSLocalizedString("empty", comment: ""), buttonTitle: NSLocalizedString("empty-button", comment: ""))
    static let noConnection = StepikPlaceholderStyle(id: "noConnection", image: PlaceholderImage(image: #imageLiteral(resourceName: "empty-nowifi"), scale: 0.35), text: NSLocalizedString("no-connection", comment: ""), buttonTitle: NSLocalizedString("no-connection", comment: ""))
}

class StepikPlaceholderContainer {
    private var placeholder: StepikPlaceholder

    init(_ placeholder: StepikPlaceholder) {
        self.placeholder = placeholder
    }

    func build() -> StepikPlaceholderView {
        let view = StepikPlaceholderView()
        view.set(id: placeholder.style.id)

        return view
    }
}
