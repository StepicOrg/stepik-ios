//
//  GradientCoursesPlaceholderView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 04.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension GradientCoursesPlaceholderView {
    struct Appearance {
        var titleFont = UIFont.systemFont(ofSize: 16)
        var subtitleFont = UIFont.systemFont(ofSize: 16)

        var titleTextAlignment = NSTextAlignment.natural
        var subtitleTextAlignment = NSTextAlignment.center

        var labelsInsets = UIEdgeInsets(top: 30, left: 28, bottom: 28, right: 30)

        init() { }
    }
}

final class GradientCoursesPlaceholderView: UIView {
    let appearance: Appearance
    private var color: Color

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.numberOfLines = 0
        label.textAlignment = self.appearance.titleTextAlignment
        label.textColor = self.color.titleTextColor
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.subtitleFont
        label.textAlignment = self.appearance.subtitleTextAlignment
        label.numberOfLines = 2
        label.textColor = self.color.subtitleTextColor
        return label
    }()

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: self.color.backgroundImage)
        return imageView
    }()

    var titleText: NSAttributedString? {
        didSet {
            self.titleLabel.attributedText = self.titleText
        }
    }

    var subtitleText: NSAttributedString? {
        didSet {
            self.subtitleLabel.isHidden = self.subtitleText == nil
            self.subtitleLabel.attributedText = self.subtitleText
        }
    }

    init(frame: CGRect, color: Color, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        self.color = color
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    enum Color {
        case purple
        case blue
        case pink

        var backgroundImage: UIImage {
            switch self {
            case .purple:
                return UIImage(named: "placeholder_gradient_purple")!
            case .blue:
                return UIImage(named: "placeholder_gradient_blue")!
            case .pink:
                return UIImage(named: "placeholder_gradient_pink")!
            }
        }

        var titleTextColor: UIColor {
            switch self {
            case .purple:
                return UIColor.white
            case .blue:
                return UIColor(hex: 0x00484e)
            case .pink:
                return UIColor(hex: 0x18073d)
            }
        }

        var subtitleTextColor: UIColor {
            return UIColor(hex: 0x535366).withAlphaComponent(0.3)
        }
    }
}

extension GradientCoursesPlaceholderView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.backgroundImageView)
        self.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.subtitleLabel)
    }

    func makeConstraints() {
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.labelsInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.labelsInsets.right)
            make.top.greaterThanOrEqualToSuperview().offset(self.appearance.labelsInsets.top)
            make.bottom.lessThanOrEqualToSuperview().offset(-self.appearance.labelsInsets.bottom)
        }
    }
}
