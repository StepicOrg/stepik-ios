//
//  Gra?dientCoursesPlaceholderViewFactory.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 02.10.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import Atributika

final class GradientCoursesPlaceholderViewFactory {
    enum Appearance {
        static let fullscreenTitleFont = UIFont.systemFont(ofSize: 20)
        static let fullscreenSubtitleFont = UIFont.systemFont(ofSize: 16)

        static let defaultTitleFont = UIFont.systemFont(ofSize: 15)

        static let defaultLabelsInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    private let color: GradientCoursesPlaceholderView.Color

    init(color: GradientCoursesPlaceholderView.Color) {
        self.color = color
    }

    func makeCourseCollectionView(
        title: String
    ) -> GradientCoursesPlaceholderView {
        var appearance = GradientCoursesPlaceholderView.Appearance()
        appearance.titleTextAlignment = .natural
        appearance.titleFont = Appearance.defaultTitleFont
        appearance.labelsInsets = Appearance.defaultLabelsInsets
        return self.makeView(
            title: title,
            subtitle: nil,
            boldStyle: .firstWord,
            appearance: appearance
        )
    }

    func makeFullscreenView(
        title: String,
        subtitle: String?
    ) -> GradientCoursesPlaceholderView {
        var appearance = GradientCoursesPlaceholderView.Appearance()
        appearance.titleTextAlignment = .center
        appearance.subtitleTextAlignment = .center
        appearance.titleFont = Appearance.fullscreenTitleFont
        appearance.subtitleFont = Appearance.fullscreenSubtitleFont
        return self.makeView(
            title: title,
            subtitle: subtitle,
            boldStyle: .allWords,
            appearance: appearance
        )
    }

    func makeInfoPlaceholder(
        message: InfoPlaceholderMessage
    ) -> GradientCoursesPlaceholderView {
        var appearance = GradientCoursesPlaceholderView.Appearance()
        appearance.titleTextAlignment = .natural
        appearance.titleFont = Appearance.defaultTitleFont
        appearance.labelsInsets = Appearance.defaultLabelsInsets
        return self.makeView(
            title: message.message,
            subtitle: nil,
            boldStyle: .useTags,
            appearance: appearance
        )
    }

    private func makeView(
        title: String,
        subtitle: String?,
        boldStyle: BoldStyle,
        appearance: GradientCoursesPlaceholderView.Appearance
    ) -> GradientCoursesPlaceholderView {
        let view = GradientCoursesPlaceholderView(
            frame: .zero,
            color: self.color,
            appearance: appearance
        )

        view.titleText = boldStyle.makeBold(string: title, fontSize: appearance.titleFont.pointSize)
        view.subtitleText = NSAttributedString(string: subtitle ?? "")
        return view
    }

    static func makeWordsBoldAndLight(
        text: String,
        firstSpaceIndex: String.Index?,
        fontSize: CGFloat
    ) -> NSAttributedString {
        let firstSpaceIndex = firstSpaceIndex ?? text.endIndex

        let rangeBold = Range<String.Index>(
            uncheckedBounds: (lower: text.startIndex, upper: firstSpaceIndex)
        )
        let rangeLight = Range<String.Index>(
            uncheckedBounds: (lower: firstSpaceIndex, upper: text.endIndex)
        )
        return text
            .style(
                range: rangeBold,
                style: .font(.systemFont(ofSize: fontSize, weight: .medium))
            ).style(
                range: rangeLight,
                style: .font(.systemFont(ofSize: fontSize, weight: .light))
            ).attributedString
    }

    static func makeWordsBoldAndLightWithTags(
        text: String,
        fontSize: CGFloat
    ) -> NSAttributedString {
        let b = Style("b").font(.systemFont(ofSize: fontSize, weight: .medium))
        let all = Style.font(.systemFont(ofSize: fontSize, weight: .light))
        return text
            .style(tags: b)
            .styleAll(all)
            .attributedString
    }

    enum BoldStyle {
        case firstWord
        case allWords
        case noWords
        case useTags

        func makeBold(string: String, fontSize: CGFloat) -> NSAttributedString {
            switch self {
            case .noWords:
                return NSAttributedString(string: string)
            case .allWords:
                return GradientCoursesPlaceholderViewFactory.makeWordsBoldAndLight(
                    text: string,
                    firstSpaceIndex: string.endIndex,
                    fontSize: fontSize
                )
            case .firstWord:
                return GradientCoursesPlaceholderViewFactory.makeWordsBoldAndLight(
                    text: string,
                    firstSpaceIndex: string.index(of: " "),
                    fontSize: fontSize
                )
            case .useTags:
                return GradientCoursesPlaceholderViewFactory.makeWordsBoldAndLightWithTags(
                    text: string,
                    fontSize: fontSize
                )
            }
        }
    }

    enum InfoPlaceholderMessage {
        case enrolled
        case login

        var message: String {
            switch self {
            case .enrolled:
                return NSLocalizedString("HomePlaceholderEmptyEnrolled", comment: "")
            case .login:
                return NSLocalizedString("HomePlaceholderAnonymous", comment: "")
            }
        }
    }
}
