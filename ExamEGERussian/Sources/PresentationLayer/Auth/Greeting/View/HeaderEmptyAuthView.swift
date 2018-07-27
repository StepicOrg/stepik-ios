//
//  HeaderEmptyAuthView.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 12/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

private struct Theme {
    struct Title {
        static let fontSize: CGFloat = 36
        static let offsetTop: CGFloat = 32.0
        static let offsetBottom: CGFloat = 16.0
    }

    struct Subtitle {
        static let fontSize: CGFloat = 17
    }

    struct Separator {
        static let height: CGFloat = 1
        static let widthMultiplier: CGFloat = 0.3
        static let offsetTop: CGFloat = 32.0
    }

    struct Description {
        static let fontSize: CGFloat = 17
        static let offsetTop: CGFloat = 32.0
        static let offsetHorizontal: CGFloat = 16.0
    }
}

@IBDesignable
public final class HeaderEmptyAuthView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: Theme.Title.fontSize, weight: .heavy)
        label.textAlignment = .center
        label.textColor = .white
        label.text = NSLocalizedString("It's You!", comment: "EmptyAuthView title")

        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: Theme.Subtitle.fontSize, weight: .medium)
        label.textAlignment = .center
        label.textColor = .white
        label.text = NSLocalizedString("Complete auth to study with comfort", comment: "EmptyAuthView subtitle")
        label.numberOfLines = 0

        return label
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white

        return view
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: Theme.Description.fontSize)
        label.textAlignment = .center
        label.textColor = .white
        label.text = NSLocalizedString("Authorized account allows you to sync progress and purchases between devices and display your name in leaderboards", comment: "EmptyAuthView description")
        label.numberOfLines = 0

        return label
    }()

    private var titleLabelTopConstraint: Constraint?

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: - Private API

    private func commonInit() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(separatorView)
        addSubview(descriptionLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            self.titleLabelTopConstraint = make.top.equalToSuperview().offset(titleTopSpacing).constraint
        }

        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(Theme.Title.offsetBottom)
        }

        separatorView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(subtitleLabel.snp.bottom).offset(Theme.Separator.offsetTop)
            make.width.equalToSuperview().multipliedBy(Theme.Separator.widthMultiplier)
            make.height.equalTo(Theme.Separator.height)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Theme.Description.offsetHorizontal)
            make.trailing.equalToSuperview().offset(-Theme.Description.offsetHorizontal)
            make.top.equalTo(separatorView.snp.bottom).offset(Theme.Description.offsetTop)
        }
    }

}

// MARK: - Public API -
// MARK: Title

public extension HeaderEmptyAuthView {

    @IBInspectable
    var titleText: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }

    @IBInspectable
    var titleFontSize: CGFloat {
        get {
            return titleLabel.font.pointSize
        }
        set {
            titleLabel.font = titleFont.withSize(newValue)
        }
    }

    @IBInspectable
    var titleTextColor: UIColor {
        get {
            return titleLabel.textColor
        }
        set {
            titleLabel.textColor = newValue
        }
    }

    @IBInspectable
    var titleTopSpacing: CGFloat {
        get {
            return titleLabelTopConstraint?.layoutConstraints[0].constant ?? Theme.Title.offsetTop
        }
        set {
            titleLabelTopConstraint?.update(offset: newValue)
        }
    }

    var titleFont: UIFont {
        get {
            return titleLabel.font
        }
        set {
            titleLabel.font = newValue
        }
    }

    var titleTextAlignment: NSTextAlignment {
        get {
            return titleLabel.textAlignment
        }
        set {
            titleLabel.textAlignment = newValue
        }
    }

}

// MARK: Subtitle

extension HeaderEmptyAuthView {

    @IBInspectable
    var subtitleText: String? {
        get {
            return subtitleLabel.text
        }
        set {
            subtitleLabel.text = newValue
        }
    }

    @IBInspectable
    var subtitleFontSize: CGFloat {
        get {
            return subtitleLabel.font.pointSize
        }
        set {
            subtitleLabel.font = subtitleFont.withSize(newValue)
        }
    }

    @IBInspectable
    var subtitleTextColor: UIColor {
        get {
            return subtitleLabel.textColor
        }
        set {
            subtitleLabel.textColor = newValue
        }
    }

    var subtitleFont: UIFont {
        get {
            return subtitleLabel.font
        }
        set {
            subtitleLabel.font = newValue
        }
    }

    var subtitleTextAlignment: NSTextAlignment {
        get {
            return subtitleLabel.textAlignment
        }
        set {
            subtitleLabel.textAlignment = newValue
        }
    }

}

// MARK: Description

extension HeaderEmptyAuthView {

    @IBInspectable
    var descriptionText: String? {
        get {
            return descriptionLabel.text
        }
        set {
            descriptionLabel.text = newValue
        }
    }

    @IBInspectable
    var descriptionFontSize: CGFloat {
        get {
            return descriptionLabel.font.pointSize
        }
        set {
            descriptionLabel.font = descriptionFont.withSize(newValue)
        }
    }

    @IBInspectable
    var descriptionTextColor: UIColor {
        get {
            return descriptionLabel.textColor
        }
        set {
            descriptionLabel.textColor = newValue
        }
    }

    var descriptionFont: UIFont {
        get {
            return descriptionLabel.font
        }
        set {
            descriptionLabel.font = newValue
        }
    }

    var descriptionTextAlignment: NSTextAlignment {
        get {
            return descriptionLabel.textAlignment
        }
        set {
            descriptionLabel.textAlignment = newValue
        }
    }

}
