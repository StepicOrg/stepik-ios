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
    var style: StepikPlaceholderStyle
    var buttonAction: (() -> Void)?

    init(_ style: StepikPlaceholderStyle, action: (() -> Void)? = nil) {
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
