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
        return [Style.empty, Style.noConnection, Style.login, Style.emptyDownloads, Style.emptyNotifications, Style.emptySearch]
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
    static let empty = StepikPlaceholderStyle(id: "empty",
                                              image: PlaceholderImage(image: #imageLiteral(resourceName: "new-empty-empty"), scale: 0.99),
                                              text: NSLocalizedString("PlaceholderEmptyText", comment: ""),
                                              buttonTitle: NSLocalizedString("PlaceholderEmptyButton", comment: ""))
    static let noConnection = StepikPlaceholderStyle(id: "noConnection",
                                                     image: PlaceholderImage(image: #imageLiteral(resourceName: "new-empty-noconnection"), scale: 0.35),
                                                     text: NSLocalizedString("PlaceholderNoConnectionText", comment: ""),
                                                     buttonTitle: NSLocalizedString("PlaceholderNoConnectionButton", comment: ""))
    static let emptyDownloads = StepikPlaceholderStyle(id: "emptyDownloads",
                                                       image: PlaceholderImage(image: #imageLiteral(resourceName: "new-empty-downloads"), scale: 0.46),
                                                       text: NSLocalizedString("PlaceholderEmptyDownloadsText", comment: ""),
                                                       buttonTitle: NSLocalizedString("PlaceholderEmptyDownloadsButton", comment: ""))
    static let login = StepikPlaceholderStyle(id: "login",
                                              image: PlaceholderImage(image: #imageLiteral(resourceName: "new-empty-login"), scale: 0.59),
                                              text: NSLocalizedString("PlaceholderLoginText", comment: ""),
                                              buttonTitle: NSLocalizedString("PlaceholderLoginButton", comment: ""))
    static let emptyNotifications = StepikPlaceholderStyle(id: "emptyNotifications",
                                                           image: PlaceholderImage(image: #imageLiteral(resourceName: "new-empty-notifications"), scale: 0.48),
                                                           text: NSLocalizedString("PlaceholderEmptyNotificationsText", comment: ""),
                                                           buttonTitle: NSLocalizedString("PlaceholderEmptyNotificationsButton", comment: ""))
    static let emptySearch = StepikPlaceholderStyle(id: "emptySearch",
                                                    image: PlaceholderImage(image: #imageLiteral(resourceName: "new-empty-search"), scale: 0.49),
                                                    text: NSLocalizedString("PlaceholderEmptySearchText", comment: ""),
                                                    buttonTitle: NSLocalizedString("PlaceholderEmptySearchButton", comment: ""))
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
